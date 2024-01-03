# share_link

[![pub package](https://img.shields.io/pub/v/share_link.svg)](https://pub.dev/packages/share_link)

Share links with UTM targeting parameters and feedback on the user-selected app.

This library allows sharing of urls using the platform-standard UI via OS integration. [UTM targeting parameters](https://en.wikipedia.org/wiki/UTM_parameters) ``utm_source`` and ``utm_medium`` are added in accordance to the sharing target the user selected. For example, if the user shares a link via WhatsApp, the utm_source will be set to "whatsapp" and the utm_medium to "social". If the user shares the link via email, the utm_source will be set to "mail" and the utm_medium to "email".

After a link was shared by the user (or not), this library provides feedback of the chosen target app. You may, for example, use this for analytics or to thank a user for sharing.

### Android

On Android an `IntentChooser` is used to share the link. Target-specific links with source/medium are supported for several well-known applications, with a fallback based on the target app's package name. 

![Sharing on Android](https://raw.githubusercontent.com/erickok/share_link/master/share_link_android.png)

On Android 10 (API level 29) and later the share targets might show up multiple times in the share sheet, due to platform limitations.

### iOS

On iOS an `UIActivityViewController` is used to share the link. Target-specific links with source/medium are supported for several well-known applications, with a fallback based on the target app's bundle identifier.

![Sharing on iOS](https://raw.githubusercontent.com/erickok/share_link/master/share_link_ios.png)

### Web

On web it attempts to use the [Web Share API](https://developer.mozilla.org/en-US/docs/Web/API/Navigator/share) if available, typically on mobile. If not, it falls back to a simple `window.open` call with a `mailto:` link that contains the shared url. The latter method will add ``utm_source=mail&utm_medium=email`` parameters to the url.

## Installation

Add to your pubspec.yaml file:

```yaml
dependencies:
  share_link: ^1.0.0
```

Import the library and call `shareUri`:

```dart
import 'package:share_link/share_link.dart';

final result = await LinkShare().shareUri(Uri.parse("https://some_link"));
```

## Limitations

Platform restrictions apply, especially on Android. Feedback on the chosen app is only available since API level 22 (Android 5). On API level 29 (Android 10) and later the share sheet may contain duplicate share targets.

Sharing of files, images or general text is unsupported. This use-case is already greatly covered by the official, community-supported [share_plus](https://pub.dev/packages/share_plus) package.

Limiting sharing to a specific (social media) app is currently unsupported.
