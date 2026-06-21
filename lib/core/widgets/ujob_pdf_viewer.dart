import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class UJobPdfViewer extends StatefulWidget {
  final String pdfUrl;
  final bool isAsset;
  final bool isLocalFile;
  final PdfViewerController? controller;

  const UJobPdfViewer({
    super.key,
    required this.pdfUrl,
    this.isAsset = false,
    this.isLocalFile = false,
    this.controller,
  });

  @override
  State<UJobPdfViewer> createState() => _UJobPdfViewerState();
}

class _UJobPdfViewerState extends State<UJobPdfViewer> {
  late PdfViewerController _pdfViewerController;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = widget.controller ?? PdfViewerController();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAsset) {
      return SfPdfViewer.asset(
        widget.pdfUrl,
        controller: _pdfViewerController,
        canShowScrollHead: false,
        canShowScrollStatus: false,
        pageLayoutMode: PdfPageLayoutMode.continuous,
        enableDoubleTapZooming: true,
      );
    } else if (widget.isLocalFile) {
      return SfPdfViewer.file(
        File(widget.pdfUrl),
        controller: _pdfViewerController,
        canShowScrollHead: false,
        canShowScrollStatus: false,
        pageLayoutMode: PdfPageLayoutMode.continuous,
        enableDoubleTapZooming: true,
      );
    } else {
      return SfPdfViewer.network(
        widget.pdfUrl,
        controller: _pdfViewerController,
        canShowScrollHead: false,
        canShowScrollStatus: false,
        pageLayoutMode: PdfPageLayoutMode.continuous,
        enableDoubleTapZooming: true,
      );
    }
  }
}
