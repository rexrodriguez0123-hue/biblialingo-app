import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  late AudioPlayer _correctPlayer;
  late AudioPlayer _incorrectPlayer;
  bool _initialized = false;

  factory AudioService() {
    return _instance;
  }

  AudioService._internal() {
    _correctPlayer = AudioPlayer();
    _incorrectPlayer = AudioPlayer();
  }

  /// Inicializar los sonidos (debe llamarse en main.dart)
  Future<void> init() async {
    if (_initialized) return;
    try {
      await _correctPlayer.setAsset('assets/audio/correct.wav');
      await _incorrectPlayer.setAsset('assets/audio/incorrect.wav');
      _initialized = true;
      print('✅ AudioService inicializado correctamente');
    } catch (e) {
      print('❌ Error inicializando AudioService: $e');
    }
  }

  /// Reproducir sonido de respuesta correcta
  Future<void> playCorrectSound() async {
    try {
      if (!_initialized) await init();
      // Resetear y reproducir desde el principio
      await _correctPlayer.seek(Duration.zero);
      await _correctPlayer.play();
      print('🔊 Reproduciendo sonido correcto');
    } catch (e) {
      print('❌ Error reproduciendo sonido correcto: $e');
    }
  }

  /// Reproducir sonido de respuesta incorrecta
  Future<void> playIncorrectSound() async {
    try {
      if (!_initialized) await init();
      // Resetear y reproducir desde el principio
      await _incorrectPlayer.seek(Duration.zero);
      await _incorrectPlayer.play();
      print('🔊 Reproduciendo sonido incorrecto');
    } catch (e) {
      print('❌ Error reproduciendo sonido incorrecto: $e');
    }
  }

  /// Detener sonido actual
  Future<void> stopSound() async {
    try {
      await _correctPlayer.stop();
      await _incorrectPlayer.stop();
    } catch (e) {
      print('❌ Error deteniendo sonidos: $e');
    }
  }

  /// Pausar sonido actual
  Future<void> pauseSound() async {
    try {
      await _correctPlayer.pause();
      await _incorrectPlayer.pause();
    } catch (e) {
      print('❌ Error pausando sonidos: $e');
    }
  }

  /// Reanudar sonido pausado
  Future<void> resumeSound() async {
    try {
      if (_correctPlayer.playing) await _correctPlayer.play();
      if (_incorrectPlayer.playing) await _incorrectPlayer.play();
    } catch (e) {
      print('❌ Error reanudando sonidos: $e');
    }
  }

  /// Establecer volumen (0.0 a 1.0)
  Future<void> setVolume(double volume) async {
    try {
      final vol = volume.clamp(0.0, 1.0);
      await _correctPlayer.setVolume(vol);
      await _incorrectPlayer.setVolume(vol);
    } catch (e) {
      print('❌ Error estableciendo volumen: $e');
    }
  }

  /// Liberar recursos
  Future<void> dispose() async {
    try {
      await _correctPlayer.dispose();
      await _incorrectPlayer.dispose();
    } catch (e) {
      print('❌ Error liberando recursos de audio: $e');
    }
  }
}
