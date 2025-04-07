# Flutter AI Toolkit Example

This is an example application demonstrating the Flutter AI Toolkit.

## Getting Started

To run this example, you need to set up your API keys and configuration files:

### Setting up Gemini API Key

1. Get your Gemini API key from [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Create a file named `gemini_api_key.dart` in the `lib` directory by copying the template:

```bash
cp lib/gemini_api_key.dart.template lib/gemini_api_key.dart
```

3. Open the `lib/gemini_api_key.dart` file and replace `'YOUR_API_KEY_HERE'` with your actual Gemini API key:

```dart
// Replace with your Gemini API key
// Get your API key from https://aistudio.google.com/app/apikey
String geminiApiKey = 'YOUR_ACTUAL_API_KEY';
```

> **Important**: Never commit your API key to version control. The `gemini_api_key.dart` file is included in `.gitignore` to prevent accidental commits.

### Setting up Firebase (for Vertex AI examples)

To use the Vertex AI examples, you need to set up Firebase:

1. Follow the instructions in the [Firebase documentation](https://firebase.google.com/docs/flutter/setup) to set up Firebase for your Flutter app
2. Run the `flutterfire` CLI tool from within the `example` directory to generate your `firebase_options.dart` file

## Running the Example

Once you've set up your API keys and configuration files, you can run the example:

```bash
flutter run
```

## Features

This example demonstrates various features of the Flutter AI Toolkit, including:

- Multi-turn chat
- Streaming responses
- Rich text display
- Voice input
- Multimedia attachments
- Custom styling
- Chat serialization/deserialization
