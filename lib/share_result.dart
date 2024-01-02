class ShareResult {
  /// Whether the sharing was successful, i.e. the uri was send to a user-selected sharing application.
  final bool success;

  /// The uri that was shared, including any UTM tracking parameters that were added.
  final Uri uri;

  /// The target of the sharing, i.e. the application that the user selected to share the uri with.
  final String? target;

  const ShareResult(this.success, this.uri, {this.target});
}
