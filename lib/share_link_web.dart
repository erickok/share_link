// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;
import 'dart:ui';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:share_link/share_result.dart';

import 'share_link_platform_interface.dart';

/// A web implementation of the ShareLinkPlatform of the ShareLink plugin.
class ShareLinkPlugin extends ShareLinkPlatform {
  ShareLinkPlugin();

  static void registerWith(Registrar registrar) {
    ShareLinkPlatform.instance = ShareLinkPlugin();
  }

  /// Attempts to share a [uri] via the Web Share API, and falls back to
  /// mailto: when not available
  ///
  /// cf https://developer.mozilla.org/en-US/docs/Web/API/Navigator/share
  ///
  /// No UTM tracking parameters are added to the [uri] when sharing via the
  /// Web Share API, as it provides no info on the selected sharing target.
  ///
  /// The [shareOrigin] is unused on web.
  @override
  Future<ShareResult> shareUri(Uri uri, {String? subject, Rect? shareOrigin}) async {
    final navigator = html.window.navigator;
    try {
      // Attempt to use the Web Share API
      await navigator.share({'url': uri.toString()});
      return ShareResult(true, uri);
    } on NoSuchMethodError catch (_) {
      // Web Share API is unavailable, fall back to mailto:
      // Add the utm_source=mail parameter to the uri
      final mailUri = uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          'utm_source': 'mail',
          'utm_medium': 'email',
        },
      );
      final mailto = Uri(
        scheme: 'mailto',
        queryParameters: {
          if (subject != null) 'subject': subject,
          'body': mailUri.toString(),
        },
      );
      try {
        // Open e-mail client to share the link
        html.window.open(mailto.toString(), '_blank');
        return ShareResult(true, mailUri, target: "mail");
      } catch (e) {
        return ShareResult(false, mailUri);
      }
    }
  }
}
