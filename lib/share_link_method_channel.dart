import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_link/share_result.dart';

import 'share_link_platform_interface.dart';

class MethodChannelShareLink extends ShareLinkPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('share_link');

  /// Shares a [uri] via a method channel which opens the platform-specific
  /// interface.
  @override
  Future<ShareResult> shareUri(Uri uri, {String? subject}) async {
    final result = (await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'shareUri',
      {
        'uri': uri.toString(),
        'subject': subject,
      },
    ))!;

    return ShareResult(
      result["success"],
      result["uri"] != null ? Uri.tryParse(result["uri"]) ?? uri : uri,
      target: result["target"],
    );
  }
}
