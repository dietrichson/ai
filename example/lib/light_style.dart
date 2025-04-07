// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

LlmChatViewStyle lightChatViewStyle() {
  final style = LlmChatViewStyle.defaultStyle();
  return LlmChatViewStyle(
    backgroundColor: Colors.white,
    progressIndicatorColor: Colors.blue,
    userMessageStyle: _lightUserMessageStyle(),
    llmMessageStyle: _lightLlmMessageStyle(),
    chatInputStyle: _lightChatInputStyle(),
    addButtonStyle: _lightActionButtonStyle(ActionButtonType.add),
    attachFileButtonStyle: _lightActionButtonStyle(ActionButtonType.attachFile),
    cameraButtonStyle: _lightActionButtonStyle(ActionButtonType.camera),
    stopButtonStyle: _lightActionButtonStyle(ActionButtonType.stop),
    recordButtonStyle: _lightActionButtonStyle(ActionButtonType.record),
    submitButtonStyle: _lightActionButtonStyle(ActionButtonType.submit),
  );
}

UserMessageStyle _lightUserMessageStyle() {
  return UserMessageStyle(
    textStyle: const TextStyle(
      color: Colors.black87,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    decoration: BoxDecoration(
      color: Colors.blue.shade100,
      borderRadius: BorderRadius.circular(12),
    ),
  );
}

LlmMessageStyle _lightLlmMessageStyle() {
  return LlmMessageStyle(
    // Completely remove the icon for a full-width look
    icon: null,
    iconColor: null,
    iconDecoration: null,
    markdownStyle: _lightMarkdownStyle(),
    // Make the decoration more transparent and flat for a full-width look
    decoration: BoxDecoration(
      // Very subtle light background
      color: Colors.grey[100],
      // No rounded corners for a flat look
      borderRadius: BorderRadius.zero,
      // Just a subtle bottom border
      border: Border(
        bottom: BorderSide(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
    ),
  );
}

ChatInputStyle _lightChatInputStyle() {
  return ChatInputStyle(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.grey[300]!),
    ),
    textStyle: const TextStyle(
      color: Colors.black87,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    hintStyle: TextStyle(
      color: Colors.grey[500],
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    hintText: 'Type a message...',
    backgroundColor: Colors.white,
  );
}

ActionButtonStyle _lightActionButtonStyle(ActionButtonType type) {
  final style = ActionButtonStyle.defaultStyle(type);
  return ActionButtonStyle(
    icon: style.icon,
    iconColor: Colors.blue,
    iconDecoration: switch (type) {
      ActionButtonType.add ||
      ActionButtonType.record ||
      ActionButtonType.stop =>
        BoxDecoration(
          color: Colors.blue.shade50,
          shape: BoxShape.circle,
        ),
      _ => BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
    },
    tooltip: style.tooltip,
    tooltipTextStyle: const TextStyle(
      color: Colors.black87,
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    tooltipDecoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
  );
}

MarkdownStyleSheet _lightMarkdownStyle() {
  // Create a light-themed markdown style
  return MarkdownStyleSheet(
    a: const TextStyle(color: Colors.blue),
    p: const TextStyle(
      color: Colors.black87,
      fontSize: 14,
      height: 1.5,
    ),
    code: TextStyle(
      backgroundColor: Colors.grey[200],
      color: Colors.black87,
      fontSize: 14,
    ),
    h1: const TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    h2: const TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    h3: const TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    h4: const TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    h5: const TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    h6: const TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    em: const TextStyle(
      color: Colors.black87,
      fontStyle: FontStyle.italic,
    ),
    strong: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    del: const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    ),
    blockquote: const TextStyle(
      color: Colors.black54,
      fontSize: 14,
    ),
    img: const TextStyle(
      color: Colors.black87,
      fontSize: 14,
    ),
    checkbox: const TextStyle(
      color: Colors.blue,
      fontSize: 14,
    ),
    tableHead: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    tableBody: const TextStyle(
      color: Colors.black87,
    ),
    listBullet: const TextStyle(
      color: Colors.black87,
    ),
  );
}
