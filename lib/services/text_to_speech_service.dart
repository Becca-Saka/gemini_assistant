import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued, error }

class TextToSpeechService {
  FlutterTts flutterTts = FlutterTts();
  TtsState ttsState = TtsState.stopped;
  void initTTS({
    required Function(TtsState ttsState) onListener,
  }) async {
    await stop();
    final voices = await flutterTts.getVoices as List<dynamic>;
    final femaleVoices = voices.where((voice) => voice['gender'] == 'female');
    debugPrint('voices ${femaleVoices.map((e) => e.toString()).join('\n')}');
    final defaultVoice =
        femaleVoices.firstWhere((voice) => voice['name'] == 'Martha');
    if (defaultVoice != null) {
      await flutterTts.setVoice(Map<String, String>.from(defaultVoice));
    }
    await flutterTts.setSharedInstance(true);
    await flutterTts.setLanguage('en-NG');
    await flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
      ],
      IosTextToSpeechAudioMode.voicePrompt,
    );
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    flutterTts.setStartHandler(() => onListener(TtsState.playing));
    flutterTts.setCompletionHandler(() => onListener(TtsState.stopped));

    flutterTts.setCancelHandler(() => onListener(TtsState.stopped));

    flutterTts.setPauseHandler(() => onListener(TtsState.paused));

    flutterTts.setContinueHandler(() => onListener(TtsState.continued));

    flutterTts.setErrorHandler((msg) => onListener(TtsState.error));
  }

  Future<TtsState> speak(String text) async {
    var result = await flutterTts.speak(text);
    if (result == 1) ttsState = TtsState.playing;
    return ttsState;
  }

  Future<TtsState> stop() async {
    var result = await flutterTts.stop();
    if (result == 1) ttsState = TtsState.stopped;
    return ttsState;
  }
}
