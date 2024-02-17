import 'dart:developer';

import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextService {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  String _lastWords = '';
  bool get isNotListening => _speechToText.isNotListening;

  /// This has to happen only once per app
  Future<void> initSpeech() async =>
      _speechEnabled = await _speechToText.initialize();

  /// Each time to start a speech recognition session
  Future<void> startListening({
    required Function(String) onSpeech,
  }) async {
    await _speechToText.stop();

    await _speechToText.listen(
      onResult: (result) {
        log('result: ${result.recognizedWords}');

        _lastWords = result.recognizedWords;

        onSpeech(_lastWords);
      },
      localeId: 'en-NG',
    );
    onSpeech(_lastWords);
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future<void> stopListening(
      {required Function(String) onSpeechStopped}) async {
    await _speechToText.stop();

    onSpeechStopped(_lastWords);
    _lastWords = '';
  }
}
