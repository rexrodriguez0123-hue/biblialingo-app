import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import '../main.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isCheckingAuth = true;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final userState = context.read<UserState>();
    final api = context.read<ApiService>();

    final token = await userState.tryRestoreToken();
    if (token != null) {
      api.setToken(token);
      try {
        final profileData = await api.getProfile();
        if (mounted) {
          final userData = profileData['user'];
          userState.setUser({
            'username': userData['username'],
            'email': userData['email'],
            'hearts': userData['profile']['hearts'],
            'gems': userData['profile']['gems'],
            'streak': userData['profile']['streak_days'],
            'totalXp': userData['profile']['total_xp'],
            'lastHeartRegen': userData['profile']['last_heart_regen'],
            'token': token,
          });
          Navigator.pushReplacementNamed(context, '/dashboard');
          return;
        }
      } catch (e) {
        // Token might be expired or invalid
        api.setToken(null);
        userState.logout();
      }
    }

    if (mounted) {
      setState(() => _isCheckingAuth = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    
    try {
      const webClientId = '697027944347-sbcolvj44n7ie3395lrp6lsm7fjakrer.apps.googleusercontent.com';

      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        serverClientId: webClientId,
      );

      // Force account selection to avoid auto-login issues if you want to switch accounts
      await googleSignIn.signOut(); 
      
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await googleSignIn.authenticate(
          scopeHint: ['email', 'profile'],
        );
      } catch (e) {
        // The user canceled the sign-in or other auth error
        if (mounted) setState(() => _isGoogleLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;


      if (idToken == null) {
        throw Exception('No se pudo obtener el ID Token de Google.');
      }

      final api = context.read<ApiService>();
      final user = await api.signInWithGoogle(idToken);
      
      if (mounted) {
        context.read<UserState>().setUser(user);
        Navigator.pushReplacementNamed(context, '/dashboard');
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión con Google:\n$e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/welcome_hero.jpg',
                height: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),
              const Text(
                'Bienvenido a\ncamino_biblico',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tu camino diario para dominar la\nReina Valera 1960',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                  icon: _isGoogleLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.g_mobiledata, size: 30),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 1,
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  label: Text(
                    _isGoogleLoading ? 'Conectando...' : 'Continuar con Google',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isGoogleLoading ? null : () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isGoogleLoading ? null : () {
                    Navigator.pushNamed(context, '/register');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.lightBlue,
                    side: const BorderSide(color: Colors.lightBlue, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Registrarse',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}




