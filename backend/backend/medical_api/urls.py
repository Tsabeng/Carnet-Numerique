from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import (
    PatientViewSet, MedicalRecordViewSet, TestResultViewSet,
    HospitalServiceViewSet, AppointmentViewSet, register,
    get_patient_appointments
)

router = DefaultRouter()
router.register(r'patients', PatientViewSet)
router.register(r'medical-records', MedicalRecordViewSet)
router.register(r'test-results', TestResultViewSet)
router.register(r'services', HospitalServiceViewSet)
router.register(r'appointments', AppointmentViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('register/', register, name='register'),
    path('patient-appointments/<uuid:patient_id>/', get_patient_appointments, name='patient_appointments'),
]