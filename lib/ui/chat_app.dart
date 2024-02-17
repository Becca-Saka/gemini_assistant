import 'package:flutter/material.dart';
import 'package:gemini_assistant/services/gemini_services.dart';
import 'package:gemini_assistant/services/speech_to_text_service.dart';
import 'package:gemini_assistant/services/text_to_speech_service.dart';

import 'expanding_circle.dart';

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  final TextToSpeechService _textToSpeechService = TextToSpeechService();
  final SpeechToTextService _speechToTextService = SpeechToTextService();
  final GerminiServices _germiniServices = GerminiServices();
  bool get _loading => _germiniServices.loading.value;
  TtsState ttsState = TtsState.stopped;
  String spokenText = '';
  @override
  void initState() {
    super.initState();
    _initGemini();
    _initSpeechServices();
  }

  void _initSpeechServices() async {
    await _speechToTextService.initSpeech();
    setState(() {});
    _textToSpeechService.initTTS(onListener: (ttsState) {
      this.ttsState = ttsState;

      debugPrint("ttsState: ${ttsState.name}");
      if (ttsState == TtsState.stopped) {
        spokenText = '';
      }
      setState(() {});
    });
  }

  void _startListening() async {
    await _textToSpeechService.stop();
    await _speechToTextService.startListening(
      onSpeech: (lastWords) {
        spokenText = lastWords;
        setState(() {});
      },
    );
  }

  Future<void> _stopListening() async {
    await _speechToTextService.stopListening(
      onSpeechStopped: (lastWords) {
        spokenText = lastWords;
        setState(() {});
        if (lastWords.isNotEmpty) {
          _sendMessage(lastWords);
        }
      },
    );
  }

  void _initGemini() => _germiniServices.init();

  Future<void> _sendMessage(String message) async {
    _germiniServices.sendMessage(
      message,
      onSuccess: (text) {
        _textToSpeechService.speak(text);
        setState(() {});
      },
      onError: (error) {
        _showError(error);
      },
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (spokenText.isNotEmpty)
            Text(spokenText,
                style: const TextStyle(
                  fontSize: 20,
                )),
          if (spokenText.isNotEmpty) const SizedBox(height: 50),
          Stack(
            alignment: Alignment.center,
            children: [
              if (!_speechToTextService.isNotListening ||
                  ttsState == TtsState.playing)
                const ExpandingCircle(
                  color: Colors.purpleAccent,
                  size: 250,
                ),
              SizedBox(
                height: 150,
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    shape: const CircleBorder(),
                  ),
                  onPressed:
                      // If not yet listening for speech start, otherwise stop
                      _speechToTextService.isNotListening
                          ? _startListening
                          : _stopListening,
                  child: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        )
                      : Icon(
                          _speechToTextService.isNotListening
                              ? Icons.mic_off
                              : Icons.mic,
                          size: 50,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
