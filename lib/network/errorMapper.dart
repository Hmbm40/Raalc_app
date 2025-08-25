import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Maps [DioException]s into user friendly messages and shows them in a [SnackBar].
///
/// The [resetLoading] callback can be provided to clear any loading state before
/// the message is shown. Unexpected errors are logged via [log].
void handleDioError(
  BuildContext context,
  Object error, {
  VoidCallback? resetLoading,
}) {
  // Always clear loading state when handling errors
  resetLoading?.call();

  String message = 'Unexpected error. Please try again.';

  if (error is DioException) {
    // Timeouts
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = 'Request timed out. Please try again.';
    }
    // Offline / no connection
    else if (error.type == DioExceptionType.connectionError ||
        error.error is SocketException) {
      message = 'No internet connection. Please check your network.';
    }
    // Validation or client side errors
    else {
      final status = error.response?.statusCode ?? 0;
      final data = error.response?.data;

      if (status == 400 || status == 401 || status == 409 || status == 422) {
        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        } else {
          message = 'Validation error. Please check your input.';
        }
      }
      // Server side errors
      else if (status >= 500) {
        message = 'Server error. Please try again later.';
        log('Server error: \\${error.response?.statusCode} ${error.message}', error: error);
      }
      // Anything else we did not anticipate
      else {
        log('Unexpected DioException: ${error.message}', error: error);
      }
    }
  } else {
    // Non Dio errors
    log('Unexpected error type: $error', error: error);
  }

  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));
}

