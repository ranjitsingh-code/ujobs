import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../theme/app_colors.dart';
import 'ujob_app_bar.dart';
import 'ujob_pdf_viewer.dart';

class UJobPdfViewerScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;
  final bool isAsset;
  final bool isLocalFile;

  const UJobPdfViewerScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
    this.isAsset = false,
    this.isLocalFile = false,
  });

  @override
  State<UJobPdfViewerScreen> createState() => _UJobPdfViewerScreenState();
}

class _UJobPdfViewerScreenState extends State<UJobPdfViewerScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: UJobAppBar(
        title: widget.title,
        rightWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedZoomInArea, color: AppColors.text, size: 24.r),
              onPressed: () {
                _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel + 0.5;
              },
            ),
            IconButton(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedZoomOutArea, color: AppColors.text, size: 24.r),
              onPressed: () {
                if (_pdfViewerController.zoomLevel > 1.0) {
                  _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel - 0.5;
                }
              },
            ),
          ],
        ),
      ),
      body: UJobPdfViewer(
        pdfUrl: widget.pdfUrl,
        isAsset: widget.isAsset,
        isLocalFile: widget.isLocalFile,
        controller: _pdfViewerController,
      ),
    );
  }
}
