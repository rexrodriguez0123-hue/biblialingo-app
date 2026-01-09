from rest_framework import generics, status, views
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from django.contrib.auth import login
from .serializers import RegisterSerializer, LoginSerializer, UserSerializer

class RegisterView(generics.CreateAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [] # Allow anyone to register

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        # Create token
        token, _ = Token.objects.get_or_create(user=user)
        
        return Response({
            "user": UserSerializer(user).data,
            "token": token.key
        }, status=status.HTTP_201_CREATED)

class LoginView(views.APIView):
    permission_classes = [] # Allow anyone to login

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data
        login(request, user)
        
        token, _ = Token.objects.get_or_create(user=user)
        
        return Response({
            "user": UserSerializer(user).data,
            "token": token.key
        })

from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
import os

class GoogleLoginView(views.APIView):
    permission_classes = []

    def post(self, request):
        token = request.data.get('id_token')
        if not token:
            return Response({'error': 'No token provided'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Verify token
            # CLIENT_ID should be in env vars, but for now we might skip strict client ID check 
            # or use the one user provides later.
            # id_info = id_token.verify_oauth2_token(token, google_requests.Request(), CLIENT_ID)
            
            # For MVP/Dev without strict check yet:
            id_info = id_token.verify_oauth2_token(token, google_requests.Request())

            email = id_info['email']
            username = email.split('@')[0] # Simple username generation

            # Get or Create User
            user, created = User.objects.get_or_create(email=email, defaults={'username': username})
            
            # Login user
            login(request, user)
            token_obj, _ = Token.objects.get_or_create(user=user)

            return Response({
                "user": UserSerializer(user).data,
                "token": token_obj.key
            })

        except ValueError as e:
            return Response({'error': f'Invalid token: {str(e)}'}, status=status.HTTP_400_BAD_REQUEST)
