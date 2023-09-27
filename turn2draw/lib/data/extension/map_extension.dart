extension OptionalDateTimeMap on Map<String, dynamic> {
  DateTime? toOptionalDateTime(String path) {
    if (this[path] != null) return DateTime.tryParse(this[path]);
    return null;
  }
}
