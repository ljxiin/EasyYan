from django.urls import path

from .views import health_check

app_name = "study"

urlpatterns = [
    path("", health_check, name="health-check"),
]
