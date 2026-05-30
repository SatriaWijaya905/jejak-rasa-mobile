class YoutubeUrlUtils {
  const YoutubeUrlUtils._();

  /// Validates a YouTube URL.
  ///
  /// Supported forms:
  /// - https://youtube.com/watch?v=VIDEO_ID
  /// - https://www.youtube.com/watch?v=VIDEO_ID
  /// - https://youtu.be/VIDEO_ID
  ///
  /// Returns a normalized full watch URL if valid, otherwise null.
  static String? normalizeYoutubeUrl(String? raw) {
    final input = raw?.trim();
    if (input == null || input.isEmpty) return null;

    // Accept only http/https
    final uri = Uri.tryParse(input);
    if (uri == null) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;

    final host = uri.host.toLowerCase();

    // 1) youtu.be/<id>
    if (host == 'youtu.be') {
      final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      if (!_isVideoId(id)) return null;
      return 'https://www.youtube.com/watch?v=$id';
    }

    // 2) youtube.com/watch?v=<id>
    final isYoutubeHost =
        host == 'youtube.com' ||
        host == 'www.youtube.com' ||
        host.endsWith('.youtube.com');

    if (isYoutubeHost) {
      // Must point to /watch
      if (uri.path != '/watch' && uri.path != 'watch') return null;

      final id = uri.queryParameters['v'] ?? '';
      if (!_isVideoId(id)) return null;
      return 'https://www.youtube.com/watch?v=$id';
    }

    return null;
  }

  static bool isValidYoutubeUrl(String? raw) {
    return normalizeYoutubeUrl(raw) != null;
  }

  // YouTube video IDs are 11 chars usually: [a-zA-Z0-9_-]
  // We'll validate len 11 and charset to be safe.
  static bool _isVideoId(String id) {
    if (id.isEmpty) return false;
    final trimmed = id.trim();
    if (trimmed.length != 11) return false;

    final validChars = RegExp(r'^[a-zA-Z0-9_-]{11}$');
    return validChars.hasMatch(trimmed);
  }
}
