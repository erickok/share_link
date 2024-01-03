import 'dart:ui';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:share_link/share_result.dart';

import 'share_link_method_channel.dart';

abstract class ShareLinkPlatform extends PlatformInterface {
  ShareLinkPlatform() : super(token: _token);

  static final Object _token = Object();

  static ShareLinkPlatform _instance = MethodChannelShareLink();

  static ShareLinkPlatform get instance => _instance;

  static set instance(ShareLinkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Shares a [uri] via the platform-specific interface.
  Future<ShareResult> shareUri(Uri uri, {String? subject, Rect? shareOrigin}) {
    throw UnimplementedError('shareUri(uri, {subject, shareOrigin}) has not been implemented for this platform.');
  }
}
