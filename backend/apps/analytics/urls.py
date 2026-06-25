from django.urls import path

from .views import health_check

app_name = "analytics"

urlpatterns = [
    path("", health_check, name="health-check"),
]
