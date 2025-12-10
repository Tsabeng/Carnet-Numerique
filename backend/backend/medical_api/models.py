from django.db import models
from django.contrib.auth.models import User
import uuid
from django.utils import timezone

class Patient(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    date_of_birth = models.DateField()
    gender = models.CharField(max_length=10, choices=[('M', 'Male'), ('F', 'Female'), ('O', 'Other')])
    blood_type = models.CharField(max_length=5, blank=True)
    address = models.TextField(blank=True)
    phone_number = models.CharField(max_length=20)
    emergency_contact = models.CharField(max_length=100)
    emergency_phone = models.CharField(max_length=20)
    qr_code = models.ImageField(upload_to='qr_codes/', blank=True, null=True)
    fingerprint_data = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.first_name} {self.last_name}"

class HospitalService(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    location = models.CharField(max_length=200)
    
    def __str__(self):
        return self.name

class MedicalRecord(models.Model):
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE, related_name='medical_records')
    service = models.ForeignKey(HospitalService, on_delete=models.SET_NULL, null=True)
    
    VISIT_TYPES = [
        ('CONSULTATION', 'Consultation'),
        ('EMERGENCY', 'Urgence'),
        ('FOLLOW_UP', 'Suivi'),
        ('HOSPITALIZATION', 'Hospitalisation'),
    ]
    
    visit_type = models.CharField(max_length=20, choices=VISIT_TYPES)
    visit_date = models.DateTimeField(default=timezone.now)
    symptoms = models.TextField()
    diagnosis = models.TextField()
    treatment = models.TextField()
    prescription = models.TextField(blank=True)
    doctor_name = models.CharField(max_length=200)
    notes = models.TextField(blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-visit_date']
    
    def __str__(self):
        return f"{self.patient} - {self.visit_date.strftime('%Y-%m-%d')}"

class TestResult(models.Model):
    medical_record = models.ForeignKey(MedicalRecord, on_delete=models.CASCADE, related_name='test_results')
    test_name = models.CharField(max_length=200)
    test_date = models.DateTimeField(default=timezone.now)
    result = models.TextField()
    file = models.FileField(upload_to='test_results/', blank=True, null=True)
    normal_range = models.CharField(max_length=100, blank=True)
    
    def __str__(self):
        return f"{self.test_name} - {self.medical_record.patient}"

class HospitalStaff(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    role = models.CharField(max_length=100)
    department = models.CharField(max_length=100)
    can_access_all = models.BooleanField(default=False)
    
    def __str__(self):
        return f"{self.first_name} {self.last_name} - {self.role}"

class Appointment(models.Model):
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    service = models.ForeignKey(HospitalService, on_delete=models.CASCADE)
    appointment_date = models.DateTimeField()
    status = models.CharField(max_length=20, choices=[
        ('SCHEDULED', 'Programmé'),
        ('IN_PROGRESS', 'En cours'),
        ('COMPLETED', 'Terminé'),
        ('CANCELLED', 'Annulé'),
    ], default='SCHEDULED')
    notes = models.TextField(blank=True)
    
    def __str__(self):
        return f"{self.patient} - {self.service} - {self.appointment_date}"

