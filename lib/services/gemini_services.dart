import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GerminiServices {
  late GenerativeModel model;
  late ChatSession chat;

  // final String prompt =
  //     "You are my personal assistant. Give the answer you find the questions below. However, if the question is beyond your capabilities, tell me 'I don't have an answer' or something more creative. \n\n  ";
  final String prompt =
      "Assume the role of a helpful AI assistant: I'm seeking your assistance with these inquiries. Respond as if you were a voice-activated device, providing clear and concise answers. If and only if a question is beyond your capabilities, acknowledge it politely.";
  // final String prompt =
  //     "You are an AI assistant, I want you to answer as an ai assistant like Siri or Alexa would answer the questions below. When you dont have an answer dont tell me you are an AI assistant. give me a mock response instead. \n\n  ";

  bool loading = false;
  // final ValueNotifier<bool> loading = ValueNotifier(false);
  List<Content> get chats => chat.history.toList();
  void init() {
    const apiKey = String.fromEnvironment('API_KEY');

    model = GenerativeModel(
      model: 'gemini-1.0-pro',
      apiKey: apiKey,
    );
    chat = model.startChat();
  }

  Future<void> sendMessage(
    String message, {
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    _setLoading(true);
    try {
      var response = await chat.sendMessage(Content.text('$prompt$message'));
      var text = response.text;
      debugPrint('text: $text');
      _setLoading(false);
      if (text == null) {
        onError('No response from API.');
        return;
      } else {
        onSuccess(text);
      }
    } catch (e) {
      onError(e.toString());
      _setLoading(false);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    loading = value;
  }
}
