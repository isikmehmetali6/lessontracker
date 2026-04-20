import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/theme/app_colors.dart';

class ErrorHandler {
  static void handleError(BuildContext context, dynamic error, {String? customMessage}) {
    String message = customMessage ?? _getErrorMessage(error);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  static String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    } else if (error is SocketException || error is TimeoutException) {
      return 'Network connection failed. Please check your internet connection.';
    } else if (error is FormatException) {
      return 'Unexpected data format encountered.';
    } else {
      // In production, you might not want to show raw errors, just returning a standard one
      // return 'An unexpected error occurred. Please try again.';
      final strError = error.toString();
      if (strError.length > 100) {
        return '${strError.substring(0, 100)}...';
      }
      return strError;
    }
  }
}
