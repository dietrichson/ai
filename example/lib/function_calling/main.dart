// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../dark_style.dart';
import '../gemini_api_key.dart';
import 'function_call_provider.dart' as fc;

void main() => runApp(const App());

class App extends StatelessWidget {
  static const title = 'Example: Function Calling';
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

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final fc.FunctionCallProvider _provider;
  final List<fc.FunctionCall> _functionCalls = [];

  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  void _initProvider() {
    // Define the schema for the function call
    final schema = Schema(
      SchemaType.object,
      properties: {
        'function_call': Schema(
          SchemaType.object,
          properties: {
            'name': Schema(
              SchemaType.string,
              enumValues: ['test_function'],
            ),
            'parameters': Schema(
              SchemaType.object,
              properties: {
                'param1': Schema(SchemaType.string),
                'param2': Schema(SchemaType.string),
              },
            ),
          },
        ),
      },
    );

    // System instructions to call the function when asked
    final systemInstructions = Content.system('''
        You are a helpful assistant that can call functions. 
        If the user asks you to call a function, call the \'test_function\' with two random parameters. 
        Only call the function when asked.
        ''');

    // Create the provider with the schema and system instructions
    _provider = fc.FunctionCallProvider(
      model: GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0,
          responseMimeType: 'application/json',
          responseSchema: schema,
        ),
        systemInstruction: systemInstructions,
      ),
      onFunctionCall: _handleFunctionCall,
    );
  }

  // Handle function calls from the LLM
  String _handleFunctionCall(fc.FunctionCall call) {
    setState(() {
      _functionCalls.add(call);
    });

    // Return a response to the function call
    return "The function has been called with these parameters: ${call.parameters}";
  }

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
        body: Column(
          children: [
            Expanded(
              child: LlmChatView(
                provider: _provider,
                style: App.themeMode.value == ThemeMode.dark
                    ? darkChatViewStyle()
                    : LlmChatViewStyle.defaultStyle(),
                welcomeMessage:
                    'Welcome to the Function Calling example! Try asking me to call a function.',
                suggestions: [
                  'Call a function for me',
                  'Can you demonstrate function calling?',
                  'Show me how function calling works',
                ],
              ),
            ),
            if (_functionCalls.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Function Calls (${_functionCalls.length}):',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _functionCalls.length,
                        itemBuilder: (context, index) {
                          final call = _functionCalls[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Function: ${call.name}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Parameters: ${call.parameters}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}

// Using FunctionCall from function_call_provider.dart
