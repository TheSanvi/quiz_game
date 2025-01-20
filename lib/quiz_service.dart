import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'quiz_model.dart';

class QuizService extends ChangeNotifier {
  Quiz? _quiz;
  bool _isLoading = false;
  String? _error;
  int _retryCount = 0;
  static const int maxRetries = 3;

  Quiz? get quiz => _quiz;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchQuiz() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _fetchWithRetry();
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        _quiz = Quiz.fromJson(jsonData);
        _error = null;
      } else {
        _error = 'Failed to load quiz data. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      _retryCount = 0;
      notifyListeners();
    }
  }

  Future<http.Response> _fetchWithRetry() async {
    while (_retryCount < maxRetries) {
      try {
        final response = await http.get(Uri.parse('https://api.jsonserve.com/Uw5CrX'))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          return response;
        }
      } catch (e) {
        if (e is TimeoutException) {
          _error = 'Request timed out. Retrying...';
        } else {
          _error = 'Network error occurred. Retrying...';
        }
      }
      _retryCount++;
      await Future.delayed(Duration(seconds: _retryCount * 2)); // Exponential backoff
    }
    throw Exception('Failed to fetch quiz data after $maxRetries attempts');
  }

  void resetError() {
    _error = null;
    notifyListeners();
  }
}


