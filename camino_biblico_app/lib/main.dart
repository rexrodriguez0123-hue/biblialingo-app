import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/practice_screen.dart';
import 'screens/settings_screen.dart';
import 'services/api_service.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar AudioService de forma segura (no debe bloquear la app)
  try {
    await AudioService().init();
    print('✅ AudioService inicializado exitosamente');
  } catch (e) {
    print('⚠️ Error inicializando AudioService (continuando sin sonido): $e');
    // Continuamos aunque falle - los sonidos simplemente no sonarán
  }
  
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => UserState()),
      ],
      child: const MyApp(),
    ),
  );
}

class UserState extends ChangeNotifier {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;

  bool get isLoggedIn => _user != null;
  String get username => _user?['username'] ?? '';
  String get email => _user?['email'] ?? '';
  int get hearts => _user?['hearts'] ?? 5;
  int get gems => _user?['gems'] ?? 0;
  int get streak => _user?['streak'] ?? 0;
  int get totalXp => _user?['totalXp'] ?? 0;
  Map<String, dynamic> get preferences => _user?['preferences'] ?? {};
  String? get token => _user?['token'];
  String? get lastHeartRegen => _user?['lastHeartRegen'];

  void setUser(Map<String, dynamic> user) {
    _user = user;
    _saveToken(user['token']);
    notifyListeners();
  }

  void updateStats({int? hearts, int? gems, int? streak, int? totalXp, Map<String, dynamic>? preferences, String? lastHeartRegen}) {
    if (_user == null) return;
    if (hearts != null) _user!['hearts'] = hearts;
    if (gems != null) _user!['gems'] = gems;
    if (streak != null) _user!['streak'] = streak;
    if (totalXp != null) _user!['totalXp'] = totalXp;
    if (preferences != null) _user!['preferences'] = preferences;
    if (lastHeartRegen != null) _user!['lastHeartRegen'] = lastHeartRegen;
    notifyListeners();
  }

  void logout() {
    _user = null;
    _clearToken();
    notifyListeners();
  }

  Future<void> _saveToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('auth_token', token);
      // Also save username for quick restore
      await prefs.setString('username', _user?['username'] ?? '');
    }
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('username');
  }

  /// Try to restore token from SharedPreferences.
  /// Returns the saved token or null.
  Future<String?> tryRestoreToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'camino_biblico',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const MainScreen(),
        '/settings': (context) => const SettingsScreen(),
        // PracticeScreen is now pushed dynamically with arguments
      },
    );
  }
}



