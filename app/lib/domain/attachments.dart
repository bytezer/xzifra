/// The record types that can own attachments.
enum AttachmentOwnerType {
  expense,
  note,
  reminder,
  bookmark;

  String get storageValue => name;

  static AttachmentOwnerType? parse(String? value) {
    for (final type in values) {
      if (type.name == value) return type;
    }
    return null;
  }
}
