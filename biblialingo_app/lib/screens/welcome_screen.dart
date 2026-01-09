import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../main.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // TODO: Replace with user provided Client ID
  // No scopes needed for basic profile (id, email)
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _handleGoogleSignIn() async {
    print('DEBUG: Attempting Google Sign-In...');
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('DEBUG: Google User is null (User canceled?)');
        return;
      }
      print('DEBUG: Google User signed in: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      print('DEBUG: ID Token retrieved: ${idToken != null ? "Yes" : "No"}');

      if (idToken != null) {
        if (!mounted) return;
        final api = context.read<ApiService>();
        print('DEBUG: Sending token to backend...');
        
        try {
          final userData = await api.signInWithGoogle(idToken);
          print('DEBUG: Update successful: $userData');
          
          if (!mounted) return;
          context.read<UserState>().setUser(userData);
          Navigator.pushReplacementNamed(context, '/dashboard');
        } catch (backendError) {
          print('DEBUG: Backend Error: $backendError');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error de servidor: $backendError')),
          );
        }
      }
    } catch (error, stackTrace) {
      print('DEBUG: Error in Google Sign-In: $error');
      print('DEBUG: StackTrace: $stackTrace');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error de Conexión'),
          content: Text('$error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.network(
                'https://cdn-icons-png.flaticon.com/512/2680/2680965.png',
                height: 200,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.menu_book_rounded,
                  size: 150,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Bienvenido a\nBibliaLingo',
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
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
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
                  onPressed: () {
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
              const SizedBox(height: 30),
              const Text(
                'O inicia sesión con',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _handleGoogleSignIn,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Icon(
                    Icons.g_mobiledata,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
