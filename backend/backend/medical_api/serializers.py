from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Patient, MedicalRecord, TestResult, HospitalService, HospitalStaff, Appointment
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token['username'] = user.username
        token['email'] = user.email
        return token

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name']

class HospitalServiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = HospitalService
        fields = '__all__'

class PatientSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = Patient
        fields = '__all__'

class MedicalRecordSerializer(serializers.ModelSerializer):
    patient = PatientSerializer(read_only=True)
    service = HospitalServiceSerializer(read_only=True)
    patient_id = serializers.UUIDField(write_only=True)
    service_id = serializers.IntegerField(write_only=True, required=False)
    
    class Meta:
        model = MedicalRecord
        fields = '__all__'

class TestResultSerializer(serializers.ModelSerializer):
    class Meta:
        model = TestResult
        fields = '__all__'

class HospitalStaffSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = HospitalStaff
        fields = '__all__'

class AppointmentSerializer(serializers.ModelSerializer):
    patient = PatientSerializer(read_only=True)
    service = HospitalServiceSerializer(read_only=True)
    patient_id = serializers.UUIDField(write_only=True)
    service_id = serializers.IntegerField(write_only=True)
    
    class Meta:
        model = Appointment
        fields = '__all__'

class QRCodeAuthSerializer(serializers.Serializer):
    qr_data = serializers.CharField()
    
class FingerprintAuthSerializer(serializers.Serializer):
    fingerprint_hash = serializers.CharField()