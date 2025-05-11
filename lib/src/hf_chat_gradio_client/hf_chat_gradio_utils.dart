import 'dart:developer' as developer;
import 'package:dio/dio.dart';

class HuggingFaceChatGradioUtils {
  static void logMessage(String message) {
    developer.log(message, name: 'GradioClient');
  }

  static void handleException(dynamic e) {
    final message =
        (e is DioException)
            ? 'Dio error: ${e.message}'
            : 'Unexpected error: $e';
    logMessage(message);
  }
}
