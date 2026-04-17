/// AI provider the user has configured for one-tap diagnosis.
enum FFAiProvider {
  /// Anthropic Claude (Messages API).
  anthropic,

  /// OpenAI / OpenAI-compatible (Chat Completions API — also works with
  /// Azure OpenAI, local Ollama proxies, etc., when `baseUrl` is overridden).
  openai,
}

/// Labels and helpers for [FFAiProvider].
extension FFAiProviderX on FFAiProvider {
  /// Human-readable name shown in UI.
  String get label {
    switch (this) {
      case FFAiProvider.anthropic:
        return 'Anthropic';
      case FFAiProvider.openai:
        return 'OpenAI';
    }
  }

  /// Default model id for the provider.
  String get defaultModel {
    switch (this) {
      case FFAiProvider.anthropic:
        return 'claude-sonnet-4-5';
      case FFAiProvider.openai:
        return 'gpt-4o-mini';
    }
  }

  /// Default public base URL.
  String get defaultBaseUrl {
    switch (this) {
      case FFAiProvider.anthropic:
        return 'https://api.anthropic.com';
      case FFAiProvider.openai:
        return 'https://api.openai.com';
    }
  }
}
