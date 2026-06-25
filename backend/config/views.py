from rest_framework.decorators import api_view
from rest_framework.response import Response


APP_ROUTES = {
    "users": "/api/users/",
    "resources": "/api/resources/",
    "subjects": "/api/subjects/",
    "questions": "/api/questions/",
    "practice": "/api/practice/",
    "papers": "/api/papers/",
    "study": "/api/study/",
    "analytics": "/api/analytics/",
}


@api_view(["GET"])
def health_check(request):
    return Response({"name": "EasyYan API", "status": "ok"})


@api_view(["GET"])
def api_root(request):
    return Response(APP_ROUTES)
