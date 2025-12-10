import os
import django
from django.utils import timezone
from datetime import datetime, timedelta

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.contrib.auth.models import User
from medical_api.models import Patient, HospitalService, MedicalRecord, HospitalStaff

# Créer des services
services = [
    {'name': 'Urgences', 'description': 'Service des urgences', 'location': 'Bâtiment A, RDC'},
    {'name': 'Radiologie', 'description': 'Service de radiologie et imagerie', 'location': 'Bâtiment B, 1er étage'},
    {'name': 'Cardiologie', 'description': 'Service de cardiologie', 'location': 'Bâtiment C, 2ème étage'},
    {'name': 'Pédiatrie', 'description': 'Service de pédiatrie', 'location': 'Bâtiment D, RDC'},
    {'name': 'Laboratoire', 'description': 'Laboratoire d\'analyses', 'location': 'Bâtiment E, Sous-sol'},
]

for service_data in services:
    HospitalService.objects.get_or_create(**service_data)

print("Services créés avec succès!")

# Créer un personnel administratif
user, created = User.objects.get_or_create(
    username='agent',
    defaults={'email': 'agent@hopital.com', 'password': 'agent123'}
)
if created:
    user.set_password('agent123')
    user.save()

staff, created = HospitalStaff.objects.get_or_create(
    user=user,
    defaults={
        'first_name': 'Agent',
        'last_name': 'Administratif',
        'role': 'Agent d\'accueil',
        'department': 'Administration'
    }
)

print("Personnel administratif créé avec succès!")

print("\nDonnées de test créées avec succès!")
print("\nInformations de connexion:")
print("Admin: username=admin, password=admin123")
print("Agent: username=agent, password=agent123")
