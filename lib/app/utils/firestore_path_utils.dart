import 'package:flutter/foundation.dart';

bool isValidFirestoreDocId(String? id) {
  if (id == null) return false;
  final trimmed = id.trim();
  if (trimmed.isEmpty) return false;
  // Firestore doc IDs are path segments. Disallow '/' to prevent invalid paths.
  if (trimmed.contains('/')) return false;
  return true;
}

String? sanitizeDocId(String? id) {
  if (!isValidFirestoreDocId(id)) return null;
  return id!.trim();
}

String requireDocId(String? id, {String label = 'Firestore doc id'}) {
  final sanitized = sanitizeDocId(id);
  if (sanitized == null) {
    throw ArgumentError('$label is null/empty/invalid');
  }
  if (kDebugMode) {
    // ignore: avoid_print
    debugPrint('[$label] => $sanitized');
  }
  return sanitized;
}
