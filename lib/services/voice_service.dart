import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      await _initSpeechToText();
      await _initTextToSpeech();
      _isInitialized = true;
    }
  }

  Future<void> _initSpeechToText() async {
    await _speechToText.initialize();
  }

  Future<void> _initTextToSpeech() async {
    await _flutterTts.setSharedInstance(true);
    await _flutterTts.awaitSpeakCompletion(true);
  }

  Future<String?> startListening({required String language}) async {
    if (!await _speechToText.hasPermission) {
      final permission = await _speechToText.requestPermissions();
      if (!permission) {
        return null;
      }
    }

    await _speechToText.listen(
      onResult: (result) {
        // Result will be handled by the callback
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: _getLanguageCode(language),
    );

    // Wait for final result
    await Future.delayed(const Duration(seconds: 1));
    return _speechToText.lastRecognizedWords;
  }

  void stop() {
    _speechToText.stop();
    _flutterTts.stop();
  }

  Future<void> speak({
    required String text,
    required String language,
    required double rate,
    required double pitch,
  }) async {
    await _flutterTts.setLanguage(_getLanguageCode(language));
    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.setPitch(pitch);
    await _flutterTts.speak(text);
  }

  String _getLanguageCode(String language) {
    switch (language) {
      case 'Urdu':
        return 'ur-PK';
      case 'Pashto':
        return 'ps-AF';
      case 'English':
      default:
        return 'en-US';
    }
  }

  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
  }
}
