// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../gemini_api_key.dart';
import '../dark_style.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  static const title = 'Example: Google Gemini AI';
  static final themeMode = ValueNotifier(ThemeMode.dark);

  const App({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
        valueListenable: themeMode,
        builder: (context, mode, child) => MaterialApp(
          title: title,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: mode,
          home: const ChatPage(),
          debugShowCheckedModeBanner: false,
        ),
      );
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(App.title),
          actions: [
            IconButton(
              onPressed: () => App.themeMode.value =
                  App.themeMode.value == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light,
              tooltip: App.themeMode.value == ThemeMode.light
                  ? 'Dark Mode'
                  : 'Light Mode',
              icon: const Icon(Icons.brightness_4_outlined),
            ),
          ],
        ),
        body: LlmChatView(
          provider: GeminiProvider(
            model: GenerativeModel(
                model: 'gemini-2.0-flash', apiKey: geminiApiKey),
          ),
          style: App.themeMode.value == ThemeMode.dark
              ? darkChatViewStyle()
              : LlmChatViewStyle.defaultStyle(),
        ),
      );
}
