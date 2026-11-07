import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  SharedPreferences? _prefs;
  bool _voiceEnabled = true;
  bool _speechEnabled = true;
  double _speechRate = 1.0;
  double _speechPitch = 1.0;
  String _voiceLanguage = 'en-US';

  bool get voiceEnabled => _voiceEnabled;
  bool get speechEnabled => _speechEnabled;
  double get speechRate => _speechRate;
  double get speechPitch => _speechPitch;
  String get voiceLanguage => _voiceLanguage;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  void _loadSettings() {
    if (_prefs == null) return;

    _voiceEnabled = _prefs!.getBool('voice_enabled') ?? true;
    _speechEnabled = _prefs!.getBool('speech_enabled') ?? true;
    _speechRate = _prefs!.getDouble('speech_rate') ?? 1.0;
    _speechPitch = _prefs!.getDouble('speech_pitch') ?? 1.0;
    _voiceLanguage = _prefs!.getString('voice_language') ?? 'en-US';
    notifyListeners();
  }

  Future<void> setVoiceEnabled(bool value) async {
    _voiceEnabled = value;
    await _prefs?.setBool('voice_enabled', value);
    notifyListeners();
  }

  Future<void> setSpeechEnabled(bool value) async {
    _speechEnabled = value;
    await _prefs?.setBool('speech_enabled', value);
    notifyListeners();
  }

  Future<void> setSpeechRate(double value) async {
    _speechRate = value;
    await _prefs?.setDouble('speech_rate', value);
    notifyListeners();
  }

  Future<void> setSpeechPitch(double value) async {
    _speechPitch = value;
    await _prefs?.setDouble('speech_pitch', value);
    notifyListeners();
  }

  Future<void> setVoiceLanguage(String value) async {
    _voiceLanguage = value;
    await _prefs?.setString('voice_language', value);
    notifyListeners();
  }
}
