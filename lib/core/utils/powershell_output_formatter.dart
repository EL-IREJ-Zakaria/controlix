class PowerShellOutputFormatter {
  PowerShellOutputFormatter._();

  static final RegExp _errorRecordPattern = RegExp(
    r'<S S="Error">(.*?)</S>',
    dotAll: true,
  );

  static String sanitize(String rawOutput) {
    final trimmed = rawOutput.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final normalized = _normalizeText(trimmed);
    if (!normalized.contains('#< CLIXML')) {
      return normalized;
    }

    final extractedErrors = _errorRecordPattern
        .allMatches(normalized)
        .map((match) => _normalizeText(match.group(1) ?? ''))
        .where((message) => message.isNotEmpty)
        .toList();

    if (extractedErrors.isNotEmpty) {
      return extractedErrors.join('\n');
    }

    return '';
  }

  static String _normalizeText(String value) {
    final decoded = _decodeXmlEntities(
      value
          .replaceAll('_x000D__x000A_', '\n')
          .replaceAll('_x000D_', '\r')
          .replaceAll('_x000A_', '\n'),
    );

    return decoded
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trimRight())
        .join('\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  static String _decodeXmlEntities(String value) {
    return value
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'");
  }
}
