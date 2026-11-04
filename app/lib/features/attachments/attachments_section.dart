import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/widgets/section_card.dart';
import '../../data/attachment_picker.dart';
import '../../data/attachment_service.dart';
import '../../data/database.dart';
import '../../domain/attachments.dart';
import '../../providers.dart';

enum _AddSource { camera, gallery, file }

class AttachmentsSection extends ConsumerStatefulWidget {
  const AttachmentsSection({
    super.key,
    required this.ownerType,
    required this.ownerId,
  });

  final AttachmentOwnerType ownerType;

  /// `null` while the owning record has not been saved yet.
  final String? ownerId;

  @override
  ConsumerState<AttachmentsSection> createState() => _AttachmentsSectionState();
}

class _AttachmentsSectionState extends ConsumerState<AttachmentsSection> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ownerId = widget.ownerId;
    if (ownerId == null) {
      return SectionCard(
        title: l10n.attachmentsTitle,
        child: Text(
          l10n.attachmentsSaveFirst,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    final attachments =
        ref
            .watch(
              attachmentsProvider((
                ownerType: widget.ownerType,
                ownerId: ownerId,
              )),
            )
            .asData
            ?.value ??
        const <Attachment>[];

    return SectionCard(
      title: l10n.attachmentsTitle,
      trailing: IconButton(
        onPressed: _busy ? null : _add,
        tooltip: l10n.attachmentsAdd,
        icon: _busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.attach_file),
      ),
      child: attachments.isEmpty
          ? Row(
              children: [
                Icon(
                  Icons.attach_file,
                  size: 18,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.attachmentsEmpty,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                for (final attachment in attachments) ...[
                  _AttachmentTile(
                    key: ValueKey(attachment.id),
                    attachment: attachment,
                    onTap: () => _view(attachment),
                    onDelete: () => _delete(attachment),
                  ),
                  if (attachment != attachments.last) const Divider(height: 1),
                ],
              ],
            ),
    );
  }

  Future<void> _add() async {
    final l10n = context.l10n;
    final source = await showModalBottomSheet<_AddSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.attachmentsAdd,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.attachmentsCamera),
              onTap: () => Navigator.of(context).pop(_AddSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.attachmentsGallery),
              onTap: () => Navigator.of(context).pop(_AddSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: Text(l10n.attachmentsFile),
              onTap: () => Navigator.of(context).pop(_AddSource.file),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final picker = ref.read(attachmentPickerProvider);
    final service = ref.read(attachmentServiceProvider);
    setState(() => _busy = true);
    try {
      final PickedAttachment? picked = switch (source) {
        _AddSource.camera => await picker.pickCamera(),
        _AddSource.gallery => await picker.pickGallery(),
        _AddSource.file => await picker.pickFile(),
      };
      if (picked == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      await service.addPicked(
        ownerType: widget.ownerType,
        ownerId: widget.ownerId!,
        picked: picked,
      );
      if (!mounted) return;
      setState(() => _busy = false);
    } on AttachmentTooLargeException {
      if (!mounted) return;
      setState(() => _busy = false);
      _showMessage(l10n.attachmentsTooLarge);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _showMessage(l10n.attachmentsAddError);
    }
  }

  Future<void> _view(Attachment attachment) async {
    final l10n = context.l10n;
    final service = ref.read(attachmentServiceProvider);
    final file = await service.resolveFile(attachment);
    if (!mounted) return;
    if (file == null) {
      _showMessage(l10n.attachmentsMissing);
      return;
    }

    if (attachment.mimeType.startsWith('image/')) {
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (context) =>
              _ImageViewerPage(title: attachment.fileName, bytes: bytes),
        ),
      );
      return;
    }

    final opened = await service.openExternally(attachment);
    if (!mounted) return;
    if (!opened) _showMessage(l10n.attachmentsOpenError);
  }

  Future<void> _delete(Attachment attachment) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.attachmentsDeleteTitle),
        content: Text(l10n.attachmentsDeleteMessage(attachment.fileName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(attachmentServiceProvider).deleteAttachment(attachment);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AttachmentTile extends ConsumerStatefulWidget {
  const _AttachmentTile({
    super.key,
    required this.attachment,
    required this.onTap,
    required this.onDelete,
  });

  final Attachment attachment;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  ConsumerState<_AttachmentTile> createState() => _AttachmentTileState();
}

class _AttachmentTileState extends ConsumerState<_AttachmentTile> {
  late Future<File?> _file;

  @override
  void initState() {
    super.initState();
    _file = ref.read(attachmentServiceProvider).resolveFile(widget.attachment);
  }

  @override
  Widget build(BuildContext context) {
    final attachment = widget.attachment;
    final image = attachment.mimeType.startsWith('image/');
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 52,
                height: 52,
                child: FutureBuilder<File?>(
                  future: _file,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    final file = snapshot.data;
                    if (file == null) {
                      return _fileIcon(theme, attachment, missing: true);
                    }
                    if (image) {
                      return Image.file(
                        file,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _fileIcon(theme, attachment, missing: true),
                      );
                    }
                    return _fileIcon(theme, attachment);
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    _sizeLabel(attachment.sizeBytes),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: widget.onDelete,
              tooltip: context.l10n.actionDelete,
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fileIcon(
    ThemeData theme,
    Attachment attachment, {
    bool missing = false,
  }) {
    if (missing) {
      return Icon(Icons.broken_image_outlined, color: theme.colorScheme.error);
    }
    final icon = switch (attachment.mimeType) {
      'application/pdf' => Icons.picture_as_pdf_outlined,
      _ when attachment.mimeType.startsWith('image/') => Icons.image_outlined,
      _ => Icons.description_outlined,
    };
    return Icon(icon, color: theme.colorScheme.primary);
  }

  String _sizeLabel(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) return '${(bytes / 1024).ceil()} KB';
    return '$bytes B';
  }
}

class _ImageViewerPage extends StatelessWidget {
  const _ImageViewerPage({required this.title, required this.bytes});

  final String title;
  final List<int> bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 5,
        child: Center(
          child: Image.memory(Uint8List.fromList(bytes), fit: BoxFit.contain),
        ),
      ),
    );
  }
}
