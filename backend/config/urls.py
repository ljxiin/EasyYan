"""
URL configuration for config project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import include, path

from .views import api_root, health_check

urlpatterns = [
    path('', health_check, name='health-check'),
    path('api/', api_root, name='api-root'),
    path('api/users/', include('apps.users.urls')),
    path('api/resources/', include('apps.resources.urls')),
    path('api/subjects/', include('apps.subjects.urls')),
    path('api/questions/', include('apps.questions.urls')),
    path('api/practice/', include('apps.practice.urls')),
    path('api/papers/', include('apps.papers.urls')),
    path('api/study/', include('apps.study.urls')),
    path('api/analytics/', include('apps.analytics.urls')),
    path('admin/', admin.site.urls),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
