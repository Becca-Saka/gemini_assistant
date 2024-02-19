import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued, error }

class TextToSpeechService {
  FlutterTts flutterTts = FlutterTts();
  TtsState ttsState = TtsState.stopped;
  void initTTS({
    required Function(TtsState ttsState) onListener,
    required Function(String, int, int, String) onProgress,
  }) async {
    await stop();
    await flutterTts.setLanguage('en-NG');
    await _setDefaultVoice();
    await flutterTts.setSharedInstance(true);
    await flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
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
    flutterTts.setProgressHandler((text, start, end, word) {
      onProgress(text, start, end, word);
    });
  }

  Future<void> _setDefaultVoice() async {
    final voices = await flutterTts.getVoices as List<dynamic>;
    Iterable defaultVoice;
    if (Platform.isIOS) {
      defaultVoice = voices.where((voice) => voice['name'] == 'Martha');
    } else {
      defaultVoice = voices.where((voice) => voice['locale'] == 'en-GB');
    }

    if (defaultVoice.isNotEmpty) {
      await flutterTts.setVoice(Map<String, String>.from(defaultVoice.first));
    }
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
