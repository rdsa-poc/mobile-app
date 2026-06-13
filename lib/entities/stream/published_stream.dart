class PublishedStream {
  const PublishedStream({
    required this.imageUrl,
    required this.streamId,
    required this.streamUrl,
    required this.summary,
    required this.title,
  });

  factory PublishedStream.fromJson(Map<String, Object?> json) {
    return PublishedStream(
      imageUrl: _readRequiredString(json, 'imageUrl'),
      streamId: _readRequiredString(json, 'streamId'),
      streamUrl: _readRequiredString(json, 'streamUrl'),
      summary: _readRequiredString(json, 'summary'),
      title: _readRequiredString(json, 'title'),
    );
  }

  final String imageUrl;
  final String streamId;
  final String streamUrl;
  final String summary;
  final String title;

  static String _readRequiredString(
    Map<String, Object?> json,
    String field,
  ) {
    final value = json[field];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Expected a non-empty string for $field.');
    }

    return value;
  }
}
