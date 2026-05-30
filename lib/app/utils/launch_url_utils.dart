import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchUrlUtils {
  static Future<void> launchYouTube(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;

    final uri = Uri.parse(trimmed);

    // Works for Android/iOS/Web.
    // - On mobile: opens external app/browser.
    // - On web: opens a new tab/window.
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
      // You can keep the default webView: since webOnlyWindowName triggers a new tab.
    );
  }
}
