from rest_framework import viewsets, status, generics
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.models import User
from django.shortcuts import get_object_or_404
import qrcode
from io import BytesIO
from django.core.files import File
import uuid

from .models import Patient, MedicalRecord, TestResult, HospitalService, HospitalStaff, Appointment
from .serializers import (
    PatientSerializer, MedicalRecordSerializer, TestResultSerializer,
    HospitalServiceSerializer, HospitalStaffSerializer, AppointmentSerializer,
    CustomTokenObtainPairSerializer, QRCodeAuthSerializer, FingerprintAuthSerializer, UserSerializer
)

class PatientViewSet(viewsets.ModelViewSet):
    queryset = Patient.objects.all()
    serializer_class = PatientSerializer
    permission_classes = [IsAuthenticated]
    
    def create(self, request):
        user_data = request.data.get('user', {})
        user = User.objects.create_user(
            username=user_data.get('username'),
            email=user_data.get('email'),
            password=user_data.get('password')
        )
        
        patient_data = request.data.copy()
        patient_data['user'] = user.id
        
        qr = qrcode.QRCode(version=1, box_size=10, border=5)
        qr_data = str(uuid.uuid4())
        qr.add_data(qr_data)
        qr.make(fit=True)
        
        img = qr.make_image(fill_color="black", back_color="white")
        buffer = BytesIO()
        img.save(buffer, format='PNG')
        
        patient_serializer = self.get_serializer(data=patient_data)
        if patient_serializer.is_valid():
            patient = patient_serializer.save()
            patient.qr_code.save(f'qr_{patient.id}.png', File(buffer))
            patient.save()
            return Response(patient_serializer.data, status=status.HTTP_201_CREATED)
        return Response(patient_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['post'])
    def qr_auth(self, request):
        serializer = QRCodeAuthSerializer(data=request.data)
        if serializer.is_valid():
            qr_data = serializer.validated_data['qr_data']
            try:
                patient = Patient.objects.get(id=qr_data)
                return Response(PatientSerializer(patient).data)
            except Patient.DoesNotExist:
                return Response({'error': 'Patient non trouvé'}, status=404)
        return Response(serializer.errors, status=400)
    
    @action(detail=False, methods=['post'])
    def fingerprint_auth(self, request):
        serializer = FingerprintAuthSerializer(data=request.data)
        if serializer.is_valid():
            fingerprint_hash = serializer.validated_data['fingerprint_hash']
            try:
                patient = Patient.objects.get(fingerprint_data=fingerprint_hash)
                return Response(PatientSerializer(patient).data)
            except Patient.DoesNotExist:
                return Response({'error': 'Patient non trouvé'}, status=404)
        return Response(serializer.errors, status=400)

class MedicalRecordViewSet(viewsets.ModelViewSet):
    queryset = MedicalRecord.objects.all()
    serializer_class = MedicalRecordSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        if self.request.user.is_superuser:
            return MedicalRecord.objects.all()
        return MedicalRecord.objects.filter(patient__user=self.request.user)
    
    def create(self, request, *args, **kwargs):
        patient_id = request.data.get('patient_id')
        service_id = request.data.get('service_id')
        
        try:
            patient = Patient.objects.get(id=patient_id)
        except Patient.DoesNotExist:
            return Response({'error': 'Patient non trouvé'}, status=404)
        
        data = request.data.copy()
        data['patient'] = patient.id
        
        if service_id:
            try:
                service = HospitalService.objects.get(id=service_id)
                data['service'] = service.id
            except HospitalService.DoesNotExist:
                pass
        
        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        
        return Response(serializer.data, status=status.HTTP_201_CREATED)

class TestResultViewSet(viewsets.ModelViewSet):
    queryset = TestResult.objects.all()
    serializer_class = TestResultSerializer
    permission_classes = [IsAuthenticated]

class HospitalServiceViewSet(viewsets.ModelViewSet):
    queryset = HospitalService.objects.all()
    serializer_class = HospitalServiceSerializer
    permission_classes = [IsAuthenticated]

class AppointmentViewSet(viewsets.ModelViewSet):
    queryset = Appointment.objects.all()
    serializer_class = AppointmentSerializer
    permission_classes = [IsAuthenticated]

@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    username = request.data.get('username')
    password = request.data.get('password')
    email = request.data.get('email')
    
    if User.objects.filter(username=username).exists():
        return Response({'error': 'Username déjà utilisé'}, status=400)
    
    user = User.objects.create_user(username=username, password=password, email=email)
    
    role = request.data.get('role')
    if role:
        HospitalStaff.objects.create(
            user=user,
            first_name=request.data.get('first_name', ''),
            last_name=request.data.get('last_name', ''),
            role=role,
            department=request.data.get('department', '')
        )
    
    return Response({'message': 'Utilisateur créé avec succès'})

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_patient_appointments(request, patient_id):
    appointments = Appointment.objects.filter(patient_id=patient_id)
    serializer = AppointmentSerializer(appointments, many=True)
    return Response(serializer.data)