import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n.dart';
import '../../data/database.dart';

/// Only http/https links are allowed; anything else is rejected before it is
/// stored or opened.
bool isValidHttpUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  return uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;
}

String bookmarkLabel(Bookmark bookmark) {
  final title = bookmark.title.trim();
  if (title.isNotEmpty) return title;
  final uri = Uri.tryParse(bookmark.url);
  return uri?.host.isNotEmpty == true ? uri!.host : bookmark.url;
}

/// Opens [url] in the user's external browser. No in-app web view is used and
/// no network permission is required by Xzifra itself.
Future<void> openBookmark(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final invalidMessage = context.l10n.bookmarksUrlError;
  final openErrorMessage = context.l10n.bookmarksOpenError;
  if (!isValidHttpUrl(url)) {
    messenger.showSnackBar(SnackBar(content: Text(invalidMessage)));
    return;
  }
  try {
    final opened = await launchUrl(
      Uri.parse(url.trim()),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(openErrorMessage)));
    }
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(openErrorMessage)));
  }
}
