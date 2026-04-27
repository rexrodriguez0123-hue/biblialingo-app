from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from django.conf import settings
from django.utils import timezone

from .serializers import RegisterSerializer, LoginSerializer, UserSerializer, UserProfileSerializer


def _regenerate_hearts(profile):
    """
    Regenerate 1 heart every 4 hours if hearts < 5.
    Call this before returning profile data.
    """
    if profile.hearts >= 5:
        return

    now = timezone.now()
    if profile.last_heart_regen is None:
        profile.last_heart_regen = now
        profile.save(update_fields=['last_heart_regen'])
        return

    hours_passed = (now - profile.last_heart_regen).total_seconds() / 3600
    hearts_to_add = int(hours_passed // 4)

    if hearts_to_add > 0:
        profile.hearts = min(5, profile.hearts + hearts_to_add)
        profile.last_heart_regen = now
        profile.save(update_fields=['hearts', 'last_heart_regen'])


@api_view(['POST'])
@permission_classes([AllowAny])
def register_view(request):
    """
    Register a new user.
    POST /api/v1/users/register/
    Body: {username, email, password}
    Returns: {user: {username, email, profile: {hearts, gems, streak_days}}, token}
    """
    serializer = RegisterSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    user = User.objects.create_user(
        username=serializer.validated_data['username'],
        email=serializer.validated_data['email'],
        password=serializer.validated_data['password'],
    )

    token, _ = Token.objects.get_or_create(user=user)

    return Response({
        'user': UserSerializer(user).data,
        'token': token.key,
    }, status=status.HTTP_201_CREATED)


@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    """
    Login with username and password.
    POST /api/v1/users/login/
    Body: {username, password}
    Returns: {user: {username, email, profile: {hearts, gems, streak_days}}, token}
    """
    serializer = LoginSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    user = authenticate(
        username=serializer.validated_data['username'],
        password=serializer.validated_data['password'],
    )

    if user is None:
        return Response(
            {'error': 'Credenciales inválidas.'},
            status=status.HTTP_401_UNAUTHORIZED,
        )

    # Regenerate hearts on login
    _regenerate_hearts(user.profile)

    token, _ = Token.objects.get_or_create(user=user)

    return Response({
        'user': UserSerializer(user).data,
        'token': token.key,
    })


@api_view(['POST'])
@permission_classes([AllowAny])
def google_login_view(request):
    """
    Login/register with Google ID token.
    POST /api/v1/users/google-login/
    Body: {id_token}
    Returns: {user: {username, email, profile: {hearts, gems, streak_days}}, token}
    """
    id_token_str = request.data.get('id_token')
    if not id_token_str:
        return Response(
            {'error': 'id_token es requerido.'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    try:
        from google.oauth2 import id_token
        from google.auth.transport import requests as google_requests

        idinfo = id_token.verify_oauth2_token(
            id_token_str,
            google_requests.Request(),
            settings.GOOGLE_CLIENT_ID,
        )

        email = idinfo.get('email')
        name = idinfo.get('name', email.split('@')[0])

        if not email:
            return Response(
                {'error': 'No se pudo obtener el email de Google.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Get or create user
        user, created = User.objects.get_or_create(
            email=email,
            defaults={'username': email.split('@')[0], 'first_name': name},
        )

        # Handle username collision for new users
        if created and User.objects.filter(username=user.username).exclude(pk=user.pk).exists():
            user.username = f"{user.username}_{user.pk}"
            user.save()

        _regenerate_hearts(user.profile)
        token, _ = Token.objects.get_or_create(user=user)

        return Response({
            'user': UserSerializer(user).data,
            'token': token.key,
        })

    except ValueError as e:
        return Response(
            {'error': f'Token de Google inválido: {str(e)}'},
            status=status.HTTP_401_UNAUTHORIZED,
        )


@api_view(['GET', 'PATCH'])
@permission_classes([IsAuthenticated])
def profile_view(request):
    """
    GET: Retrieve the authenticated user's profile (with heart regen).
    PATCH: Update the authenticated user's profile.
    """
    profile = request.user.profile

    # Always regenerate hearts on profile access
    _regenerate_hearts(profile)

    if request.method == 'GET':
        return Response({
            'user': UserSerializer(request.user).data,
        })

    elif request.method == 'PATCH':
        serializer = UserProfileSerializer(profile, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({
            'user': UserSerializer(request.user).data,
        })


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def shop_purchase_view(request):
    """
    POST /api/v1/users/shop/purchase/
    Body: {item_type: "refill_hearts" | "streak_freeze"}

    refill_hearts: costs 50 gems → hearts = 5
    streak_freeze: costs 100 gems → grants 1 day streak protection
    """
    item_type = request.data.get('item_type')
    profile = request.user.profile

    SHOP_ITEMS = {
        'refill_hearts': {
            'cost': 50,
            'name': 'Rellenar Corazones',
        },
        'streak_freeze': {
            'cost': 100,
            'name': 'Streak Freeze',
        },
    }

    if item_type not in SHOP_ITEMS:
        return Response(
            {'error': f'Item no válido. Opciones: {list(SHOP_ITEMS.keys())}'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    item = SHOP_ITEMS[item_type]

    if profile.gems < item['cost']:
        return Response(
            {
                'error': 'No tienes suficientes gemas.',
                'gems_needed': item['cost'],
                'gems_current': profile.gems,
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

    # Deduct gems
    profile.gems -= item['cost']

    # Apply item effect
    if item_type == 'refill_hearts':
        profile.hearts = 5
        profile.last_heart_regen = timezone.now()
    elif item_type == 'streak_freeze':
        # Store streak freeze in preferences
        prefs = profile.theological_preferences or {}
        prefs['streak_freeze_until'] = (
            timezone.now() + timezone.timedelta(days=1)
        ).isoformat()
        profile.theological_preferences = prefs

    profile.save()

    return Response({
        'success': True,
        'item': item['name'],
        'gems_remaining': profile.gems,
        'hearts': profile.hearts,
        'user': UserSerializer(request.user).data,
    })

