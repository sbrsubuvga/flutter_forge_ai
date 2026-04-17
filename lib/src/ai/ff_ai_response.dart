import 'package:flutter/foundation.dart';

/// Result of a completed AI diagnosis call.
@immutable
class FFAiResponse {
  /// Creates a response.
  const FFAiResponse({
    required this.text,
    required this.provider,
    required this.model,
    this.promptTokens,
    this.completionTokens,
    this.finishReason,
  });

  /// The assistant message body.
  final String text;

  /// Which provider produced this (anthropic / openai).
  final String provider;

  /// Resolved model id used for the request.
  final String model;

  /// Optional token counts — null when the provider doesn't report them.
  final int? promptTokens;

  /// Completion tokens used, if reported.
  final int? completionTokens;

  /// Why the model stopped (`stop`, `length`, `max_tokens`, …).
  final String? finishReason;

  /// JSON form for logs / downstream tools.
  Map<String, Object?> toJson() => <String, Object?>{
        'provider': provider,
        'model': model,
        'finish_reason': finishReason,
        'prompt_tokens': promptTokens,
        'completion_tokens': completionTokens,
        'text_length': text.length,
      };
}

/// Exception thrown when an AI call fails.
class FFAiException implements Exception {
  /// Creates an exception.
  FFAiException(this.message, {this.statusCode, this.providerBody});

  /// Developer-facing message.
  final String message;

  /// HTTP status code returned by the provider, if any.
  final int? statusCode;

  /// Raw body returned by the provider (kept for easier debugging).
  final Object? providerBody;

  @override
  String toString() => 'FFAiException($statusCode): $message';
}
