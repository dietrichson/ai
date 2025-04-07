// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// Class to represent a function call
class FunctionCall {
  final String name;
  final Map<String, dynamic> parameters;

  FunctionCall({required this.name, required this.parameters});

  @override
  String toString() => 'FunctionCall(name: $name, parameters: $parameters)';
}

// Type definition for function call handler
typedef FunctionCallHandler = String Function(FunctionCall call);

// Extension of GeminiProvider that supports function calling
class FunctionCallProvider extends GeminiProvider {
  FunctionCallProvider({
    required GenerativeModel model,
    required this.onFunctionCall,
    Iterable<ChatMessage>? history,
    List<SafetySetting>? chatSafetySettings,
    GenerationConfig? chatGenerationConfig,
  }) : super(
          model: model,
          history: history,
          chatSafetySettings: chatSafetySettings,
          chatGenerationConfig: chatGenerationConfig,
        );

  final FunctionCallHandler onFunctionCall;

  @override
  Stream<String> sendMessageStream(
    String prompt, {
    Iterable<Attachment> attachments = const [],
  }) async* {
    try {
      debugPrint('DEBUG: Starting sendMessageStream with prompt: $prompt');
      final userMessage = ChatMessage.user(prompt, attachments);
      final llmMessage = ChatMessage.llm();
      history = [...history, userMessage, llmMessage];

      // Generate the response
      debugPrint('DEBUG: Calling super.generateStream');
      final responseStream = super.generateStream(
        prompt,
        attachments: attachments,
      );

      String fullResponse = '';

      // Collect the full response
      debugPrint('DEBUG: Starting to collect response chunks');
      await for (final chunk in responseStream) {
        debugPrint('DEBUG: Received chunk: $chunk');
        fullResponse += chunk;
        llmMessage.append(chunk);
        yield chunk;
      }
      debugPrint('DEBUG: Full response collected: $fullResponse');

      // Check if the response contains a function call
      try {
        // Parse the response to look for tool calls
        debugPrint('DEBUG: Checking for function calls in response');
        if (fullResponse.contains('"functionCall"') ||
            fullResponse.contains('"function_call"') ||
            fullResponse.contains('"tool_calls"') ||
            fullResponse.contains('"toolCalls"')) {
          debugPrint('DEBUG: Function call keywords found in response');

          // Try to extract the function call information
          Map<String, dynamic>? jsonResponse;
          try {
            debugPrint('DEBUG: Attempting to parse full response as JSON');
            jsonResponse = jsonDecode(fullResponse);
            debugPrint('DEBUG: Successfully parsed JSON: $jsonResponse');
          } catch (e) {
            debugPrint('DEBUG: Failed to parse full response as JSON: $e');
            // If the full response isn't valid JSON, try to extract just the function call part
            debugPrint('DEBUG: Attempting to extract function call using regex');
            final functionCallRegex =
                r'\{\s*"(function_call|functionCall|tool_calls|toolCalls)"\s*:\s*\{.*?\}\s*\}';
            debugPrint('DEBUG: Using regex: $functionCallRegex');
            final functionCallMatch =
                RegExp(functionCallRegex, dotAll: true).firstMatch(fullResponse);

            if (functionCallMatch != null) {
              final functionCallJson = functionCallMatch.group(0);
              debugPrint('DEBUG: Extracted function call JSON: $functionCallJson');
              if (functionCallJson != null) {
                try {
                  jsonResponse = jsonDecode(functionCallJson);
                  debugPrint(
                      'DEBUG: Successfully parsed extracted JSON: $jsonResponse');
                } catch (e) {
                  debugPrint('DEBUG: Failed to parse extracted JSON: $e');
                }
              }
            } else {
              debugPrint('DEBUG: No function call match found with regex');
            }
          }

          if (jsonResponse != null) {
            debugPrint('DEBUG: Processing JSON response: $jsonResponse');

            // Check for different possible formats of function calls
            final functionCallData =
                jsonResponse['function_call'] ?? jsonResponse['functionCall'];

            // Check for tool calls format
            final toolCalls =
                jsonResponse['tool_calls'] ?? jsonResponse['toolCalls'];

            if (functionCallData != null) {
              debugPrint('DEBUG: Found function call data: $functionCallData');
              final functionCall = FunctionCall(
                name: functionCallData['name'],
                parameters: functionCallData['parameters'] ??
                    functionCallData['args'] ??
                    {},
              );

              debugPrint('DEBUG: Created FunctionCall object: $functionCall');
              // Call the function handler
              final functionResponse = onFunctionCall(functionCall);
              debugPrint('DEBUG: Function handler returned: $functionResponse');

              // Append the function response to the LLM message
              llmMessage.append('\n\n$functionResponse');
              yield '\n\n$functionResponse';
            } else if (toolCalls != null) {
              // Handle tool calls format (array or single object)
              debugPrint('DEBUG: Found tool calls: $toolCalls');
              List<dynamic> toolCallsList;

              if (toolCalls is List) {
                toolCallsList = toolCalls;
              } else {
                toolCallsList = [toolCalls];
              }

              for (final toolCall in toolCallsList) {
                debugPrint('DEBUG: Processing tool call: $toolCall');
                final function = toolCall['function'] ?? {};
                final functionCall = FunctionCall(
                  name: function['name'] ?? '',
                  parameters: function['parameters'] ?? function['args'] ?? {},
                );

                debugPrint(
                    'DEBUG: Created FunctionCall object from tool call: $functionCall');
                // Call the function handler
                final functionResponse = onFunctionCall(functionCall);
                debugPrint('DEBUG: Function handler returned: $functionResponse');

                // Append the function response to the LLM message
                llmMessage.append('\n\n$functionResponse');
                yield '\n\n$functionResponse';
              }
            } else {
              debugPrint('DEBUG: No function call or tool calls found in JSON');
            }
          } else {
            debugPrint('DEBUG: No valid JSON response found');
          }
        } else {
          debugPrint('DEBUG: No function call keywords found in response');
        }
      } catch (e) {
        // Error handling function call parsing
        debugPrint('DEBUG ERROR: Error parsing function call: $e');
        debugPrint('DEBUG ERROR: Stack trace: ${StackTrace.current}');
      }

      // Notify listeners that the history has changed
      debugPrint('DEBUG: Notifying listeners of history change');
      notifyListeners();
    } catch (e, stackTrace) {
      // Catch any errors in the overall process
      debugPrint('CRITICAL ERROR: Error in sendMessageStream: $e');
      debugPrint('CRITICAL ERROR: Stack trace: $stackTrace');
      // Re-throw as LlmException so it can be properly handled by the UI
      throw LlmFailureException('Error processing message: $e');
    }
  }
}

// Implementation of the add numbers function
String addNumbers(int a, int b) {
  return "The sum of $a and $b is ${a + b}";
}

// Implementation of the random number function
String getRandomNumber() {
  final random = Random();
  final randomNumber = random.nextInt(100) + 1; // Random number between 1 and 100
  return "Your random number is: $randomNumber";
}
