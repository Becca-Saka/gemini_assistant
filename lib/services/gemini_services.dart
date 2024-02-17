import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GerminiServices {
  late GenerativeModel model;
  late ChatSession chat;
  final String prompt =
      "Your task is to provide a detailed answer to the user's question. If you can't answer the question, just say 'I don't know'. The user's question is: ";
  // final String prompt =
  //     "Assume the role of a helpful AI assistant: I'm seeking your assistance with these inquiries. Respond as if you were a voice-activated device, providing clear and concise answers. If and only if a question is beyond your capabilities, acknowledge it politely.";
  // final String prompt =
  //     "You are an AI assistant, I want you to answer as an ai assistant like Siri or Alexa would answer the questions below. When you dont have an answer dont tell me you are an AI assistant. give me a mock response instead. \n\n  ";
  final ValueNotifier<bool> loading = ValueNotifier(false);
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
    loading.value = true;

    try {
      var response = await chat.sendMessage(Content.text('$prompt$message'));
      var text = response.text;
      debugPrint('text: $text');
      if (text == null) {
        onError('No response from API.');
        return;
      } else {
        onSuccess(text);

        loading.value = false;
      }
    } catch (e) {
      onError(e.toString());

      loading.value = false;
    } finally {
      loading.value = false;
    }
  }
}