import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

class PickedAttachment {
  const PickedAttachment({
    required this.fileName,
    required this.bytes,
    this.mimeType,
  });

  final String fileName;
  final List<int> bytes;
  final String? mimeType;
}

/// Picker abstraction so attachments can be tested without native plugins.
abstract class AttachmentPicker {
  Future<PickedAttachment?> pickCamera();

  Future<PickedAttachment?> pickGallery();

  Future<PickedAttachment?> pickFile();
}

class DeviceAttachmentPicker implements AttachmentPicker {
  DeviceAttachmentPicker({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  static const List<String> documentExtensions = [
    'pdf',
    'png',
    'jpg',
    'jpeg',
    'webp',
    'gif',
    'heic',
    'heif',
  ];

  @override
  Future<PickedAttachment?> pickCamera() => _pickImage(ImageSource.camera);

  @override
  Future<PickedAttachment?> pickGallery() => _pickImage(ImageSource.gallery);

  Future<PickedAttachment?> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 2000,
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    final fileName = picked.name.isNotEmpty
        ? picked.name
        : p.basename(picked.path);
    return PickedAttachment(
      fileName: fileName,
      bytes: bytes,
      mimeType: picked.mimeType ?? lookupMimeType(fileName),
    );
  }

  @override
  Future<PickedAttachment?> pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: documentExtensions,
    );
    if (result.isEmpty) return null;
    final picked = result.first;
    return PickedAttachment(
      fileName: picked.name,
      bytes: await picked.readAsBytes(),
      mimeType: lookupMimeType(picked.name),
    );
  }
}
