from django.urls import path
from . import views

urlpatterns = [
    path('register/', views.register_view, name='user-register'),
    path('login/', views.login_view, name='user-login'),
    path('google-login/', views.google_login_view, name='user-google-login'),
    path('profile/', views.profile_view, name='user-profile'),
    path('shop/purchase/', views.shop_purchase_view, name='shop-purchase'),
]

