// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_generative_ai/google_generative_ai.dart';
import '../gemini_api_key.dart';

void main() async {
  final genAI = GenerativeModel(
    model: 'gemini-1.5-pro',
    apiKey: geminiApiKey,
  );

  try {
    // Try to list available models
    print('Attempting to list available models...');
    
    // This is a simple test to see if the model can generate content
    final response = await genAI.generateContent([Content.text('Hello')]);
    print('Model response: ${response.text}');
    
    // Print model information
    print('Model name: ${genAI.model}');
    print('API version: v1beta');
    
  } catch (e) {
    print('Error: $e');
  }
}
