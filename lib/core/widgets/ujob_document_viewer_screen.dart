import 'dart:io';

import 'package:dio/dio.dart';
import 'package:docx_viewer_plus/docx_viewer_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/l10n_extensions.dart';
import 'ujob_app_bar.dart';
import 'ujob_pdf_viewer.dart';
import 'ujob_toast.dart';

class UJobDocumentViewerScreen extends ConsumerStatefulWidget {
  final String title;
  final String fileUrl;
  final String? fileName;

  const UJobDocumentViewerScreen({
    super.key,
    required this.title,
    required this.fileUrl,
    this.fileName,
  });

  @override
  ConsumerState<UJobDocumentViewerScreen> createState() =>
      _UJobDocumentViewerScreenState();
}

class _UJobDocumentViewerScreenState
    extends ConsumerState<UJobDocumentViewerScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  late final String _extension;
  bool _loadingDocument = false;
  String? _localDocumentPath;
  String? _documentError;

  bool get _isPdf => _extension == 'pdf';
  bool get _isDocFamily => _isDoc || _isDocx;
  bool get _isDoc => _extension == 'doc';
  bool get _isDocx => _extension == 'docx';

  @override
  void initState() {
    super.initState();
    _extension = _resolveExtension();
    if (_isDocFamily) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prepareDocument();
      });
    }
  }

  String _resolveExtension() {
    final source =
        (widget.fileName?.isNotEmpty == true
                ? widget.fileName!
                : widget.fileUrl)
            .toLowerCase();
    final sanitized = source.split('?').first.split('#').first;
    final dotIndex = sanitized.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return sanitized.substring(dotIndex + 1);
  }

  Future<void> _prepareDocument() async {
    if (_loadingDocument) return;
    final l10n = context.l10n;
    setState(() {
      _loadingDocument = true;
      _documentError = null;
    });

    try {
      final response = await ref
          .read(dioClientProvider)
          .dio
          .get<List<int>>(
            widget.fileUrl,
            options: Options(responseType: ResponseType.bytes),
          );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw Exception(l10n.documentEmptyError);
      }

      final tempDir = await getTemporaryDirectory();
      final safeName =
          (widget.fileName?.trim().isNotEmpty == true
                  ? widget.fileName!.trim()
                  : 'document.${_extension.isEmpty ? 'file' : _extension}')
              .replaceAll('/', '_')
              .replaceAll('\\', '_');
      final file = File('${tempDir.path}/$safeName');
      await file.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      setState(() {
        _localDocumentPath = file.path;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _documentError = l10n.couldNotLoadDocument;
      });
    } finally {
      if (mounted) {
        setState(() => _loadingDocument = false);
      }
    }
  }

  Future<void> _openDocumentExternally() async {
    final localPath = _localDocumentPath;
    if (localPath == null || localPath.isEmpty) return;
    final result = await OpenFilex.open(localPath);
    if (!mounted) return;
    if (result.type != ResultType.done) {
      UJobToast.error(
        context,
        context.l10n.couldNotOpenDocument,
        sub: result.message.isNotEmpty
            ? result.message
            : context.l10n.noSupportedAppFound,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: UJobAppBar(
        title: widget.title,
        rightWidget: _isPdf
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedZoomInArea,
                      color: AppColors.text,
                      size: 24.r,
                    ),
                    onPressed: () {
                      _pdfViewerController.zoomLevel =
                          _pdfViewerController.zoomLevel + 0.5;
                    },
                  ),
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedZoomOutArea,
                      color: AppColors.text,
                      size: 24.r,
                    ),
                    onPressed: () {
                      if (_pdfViewerController.zoomLevel > 1.0) {
                        _pdfViewerController.zoomLevel =
                            _pdfViewerController.zoomLevel - 0.5;
                      }
                    },
                  ),
                ],
              )
            : null,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isPdf) {
      return UJobPdfViewer(
        pdfUrl: widget.fileUrl,
        isAsset: false,
        isLocalFile: false,
        controller: _pdfViewerController,
      );
    }

    if (_isDocFamily) {
      if (_loadingDocument) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }
      if (_documentError != null) {
        return _ErrorState(message: _documentError!, onRetry: _prepareDocument);
      }
      if (_localDocumentPath == null) {
        return _ErrorState(
          message: context.l10n.couldNotLoadDocument,
          onRetry: _prepareDocument,
        );
      }
      if (_isDoc) {
        return _LegacyDocFallback(
          onOpenExternally: _openDocumentExternally,
          onRetry: _prepareDocument,
        );
      }
      return DocxViewerWidget(
        filePath: _localDocumentPath!,
        config: const DocxViewerConfig(
          isReadOnly: true,
          toolbarPosition: ToolbarPosition.bottom,
        ),
      );
    }

    return _ErrorState(message: context.l10n.fileTypeNotSupportedInPreview);
  }
}

class _LegacyDocFallback extends StatelessWidget {
  final VoidCallback onOpenExternally;
  final VoidCallback onRetry;

  const _LegacyDocFallback({
    required this.onOpenExternally,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedFile02,
              color: AppColors.seekPrimary,
              size: 36.r,
            ),
            SizedBox(height: 12.h),
            Text(
              context.l10n.legacyDocNotSupported,
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(color: AppColors.muted),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onOpenExternally,
                icon: const Icon(Icons.open_in_new),
                label: Text(context.l10n.openWithDeviceViewer),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRetry,
                child: Text(context.l10n.retry),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorState({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedAlert02,
              color: AppColors.error,
              size: 32.r,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(color: AppColors.muted),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              SizedBox(
                width: 140.w,
                child: OutlinedButton(
                  onPressed: onRetry,
                  child: Text(context.l10n.retry),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
