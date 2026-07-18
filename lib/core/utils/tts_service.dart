import 'package:flutter_tts/flutter_tts.dart';

/// Thin wrapper around flutter_tts configured for offline American
/// English pronunciation. flutter_tts uses each platform's built-in,
/// on-device speech engine (iOS AVSpeechSynthesizer / Android TextToSpeech),
/// so no network access is required once the voice is installed.
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _ensureInit(double rate) async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(rate);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    _initialized = true;
  }

  Future<void> speak(String text, {double rate = 0.45}) async {
    await _ensureInit(rate);
    await _tts.setSpeechRate(rate);
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
