// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:permission_handler/permission_handler.dart';

import 'permission_handler.dart' as ph;

/// A wrapper widget that handles permissions for the LlmChatView.
class PermissionAwareChatView extends StatefulWidget {
  /// Creates a [PermissionAwareChatView] widget.
  const PermissionAwareChatView({
    required this.provider,
    this.style,
    this.welcomeMessage,
    this.suggestions = const [],
    this.onErrorCallback,
    this.cancelMessage = 'CANCEL',
    this.errorMessage = 'ERROR',
    super.key,
  });

  /// The LLM provider to use for chat interactions.
  final LlmProvider provider;

  /// The style to apply to the chat view.
  final LlmChatViewStyle? style;

  /// The welcome message to display when the chat is first opened.
  final String? welcomeMessage;

  /// A list of predefined suggestions to display when the chat history is empty.
  final List<String> suggestions;

  /// The action to perform when an error occurs during a chat operation.
  final void Function(BuildContext, LlmException)? onErrorCallback;

  /// The message to display when the user cancels a chat operation.
  final String cancelMessage;

  /// The message to display when an error occurs during a chat operation.
  final String errorMessage;

  @override
  State<PermissionAwareChatView> createState() => _PermissionAwareChatViewState();
}

class _PermissionAwareChatViewState extends State<PermissionAwareChatView> {
  bool _permissionsChecked = false;
  bool _microphonePermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.microphone.status;
    setState(() {
      _permissionsChecked = true;
      _microphonePermissionGranted = status.isGranted;
    });
  }

  Future<void> _requestPermissions() async {
    final hasPermission = await ph.PermissionHandler.requestMicrophonePermission(context);
    setState(() {
      _microphonePermissionGranted = hasPermission;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsChecked) {
      // Show loading indicator while checking permissions
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (!_microphonePermissionGranted)
          Container(
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).colorScheme.errorContainer,
            child: Row(
              children: [
                Icon(
                  Icons.mic_off,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Microphone permission is required for voice notes',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _requestPermissions,
                  child: const Text('Grant'),
                ),
              ],
            ),
          ),
        Expanded(
          child: LlmChatView(
            provider: widget.provider,
            style: widget.style,
            welcomeMessage: widget.welcomeMessage,
            suggestions: widget.suggestions,
            enableVoiceNotes: _microphonePermissionGranted,
            onErrorCallback: widget.onErrorCallback,
            cancelMessage: widget.cancelMessage,
            errorMessage: widget.errorMessage,
          ),
        ),
      ],
    );
  }
}
