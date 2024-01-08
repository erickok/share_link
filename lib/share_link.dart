import 'dart:ui';

import 'package:share_link/share_result.dart';

import 'share_link_platform_interface.dart';

class ShareLink {
  /// Shares a [uri] via the platform-specific interface. When possible, UTM
  /// tracking parameters are added to the [uri].
  ///
  /// On iOS and Android the [uri] is shared via the platform's share sheet.
  /// A preview is shown on iOS and Android versions 10 and up.
  ///
  /// The [subject] is only used when sharing via email.
  ///
  /// The [shareOrigin] is only used (and required) on iPhone and iPad and is
  /// used to position the share.
  static Future<ShareResult> shareUri(Uri uri,
      {String? subject, Rect? shareOrigin}) {
    return ShareLinkPlatform.instance
        .shareUri(uri, subject: subject, shareOrigin: shareOrigin);
  }
}
