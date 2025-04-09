// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// A utility class to handle permissions for the function calling examples.
class PermissionHandler {
  /// Requests microphone permission and returns whether it was granted.
  static Future<bool> requestMicrophonePermission(BuildContext context) async {
    // Check current permission status
    PermissionStatus status = await Permission.microphone.status;
    
    // If permission is already granted, return true
    if (status.isGranted) {
      return true;
    }
    
    // If permission is denied but can be requested, request it
    if (status.isDenied) {
      status = await Permission.microphone.request();
      return status.isGranted;
    }
    
    // If permission is permanently denied, show a dialog to open app settings
    if (status.isPermanentlyDenied) {
      final result = await _showPermissionDialog(
        context,
        'Microphone Permission Required',
        'Voice notes require microphone access. Please enable it in app settings.',
      );
      
      if (result == true) {
        await openAppSettings();
      }
      
      return false;
    }
    
    return false;
  }
  
  /// Shows a permission dialog and returns whether the user chose to open settings.
  static Future<bool?> _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
