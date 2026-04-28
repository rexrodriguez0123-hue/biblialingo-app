import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  late AudioPlayer _audioPlayer;

  factory AudioService() {
    return _instance;
  }

  AudioService._internal() {
    _audioPlayer = AudioPlayer();
  }

  /// Reproducir sonido de respuesta correcta
  Future<void> playCorrectSound() async {
    try {
      await _audioPlayer.setAsset('assets/audio/correct.wav');
      await _audioPlayer.play();
    } catch (e) {
      print('Error reproduciendo sonido correcto: $e');
    }
  }

  /// Reproducir sonido de respuesta incorrecta
  Future<void> playIncorrectSound() async {
    try {
      await _audioPlayer.setAsset('assets/audio/incorrect.wav');
      await _audioPlayer.play();
    } catch (e) {
      print('Error reproduciendo sonido incorrecto: $e');
    }
  }

  /// Detener sonido actual
  Future<void> stopSound() async {
    await _audioPlayer.stop();
  }

  /// Pausar sonido actual
  Future<void> pauseSound() async {
    await _audioPlayer.pause();
  }

  /// Reanudar sonido pausado
  Future<void> resumeSound() async {
    await _audioPlayer.play();
  }

  /// Establecer volumen (0.0 a 1.0)
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Liberar recursos
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
