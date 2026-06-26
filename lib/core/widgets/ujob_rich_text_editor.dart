import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobRichTextEditor extends StatefulWidget {
  final String title;
  final String initialValue;
  final ValueChanged<String> onSave;

  const UJobRichTextEditor({
    required this.title,
    required this.initialValue,
    required this.onSave,
    super.key,
  });

  @override
  State<UJobRichTextEditor> createState() => _UJobRichTextEditorState();
}

class _UJobRichTextEditorState extends State<UJobRichTextEditor> {
  late QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: _parseInitialValue(widget.initialValue),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  Document _parseInitialValue(String value) {
    if (value.isEmpty) return Document();
    try {
      return Document.fromJson(jsonDecode(value));
    } catch (e) {
      if (value.contains('<') && value.contains('>')) {
        try {
          final delta = HtmlToDelta().convert(value);
          return Document.fromDelta(delta);
        } catch (_) {}
      }
      final doc = Document();
      doc.insert(0, value);
      return doc;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    final jsonStr = jsonEncode(_controller.document.toDelta().toJson());
    widget.onSave(jsonStr);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderLight),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title, style: AppText.heading3),
                  GestureDetector(
                    onTap: _handleSave,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Done',
                        style: AppText.small.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            QuillSimpleToolbar(
              controller: _controller,
              config: const QuillSimpleToolbarConfig(
                // History
                showUndo: true,
                showRedo: true,
                // Headings
                showHeaderStyle: true,
                // Inline Formatting
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showStrikeThrough: true,
                // Alignment
                showAlignmentButtons: false,
                showLeftAlignment: true,
                showCenterAlignment: true,
                showRightAlignment: true,
                showJustifyAlignment: false,
                // Lists
                showListBullets: true,
                showListNumbers: true,
                // Inserts
                showQuote: true,
                showLink: true,

                // Hide everything else
                showFontFamily: false,
                showFontSize: false,
                showSmallButton: false,
                showLineHeightButton: false,
                showInlineCode: false,
                showColorButton: false,
                showBackgroundColorButton: false,
                showClearFormat: false,
                showListCheck: false,
                showCodeBlock: false,
                showIndent: false,
                showDirection: false,
                showSearchButton: false,
                showSubscript: false,
                showSuperscript: false,
                showClipboardCut: false,
                showClipboardCopy: false,
                showClipboardPaste: false,
              ),
            ),
            Divider(color: AppColors.borderLight, height: 1),
            Expanded(
              child: Container(
                color: AppColors.surface,
                padding: EdgeInsets.all(20.r),
                child: QuillEditor.basic(controller: _controller),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper method to open the editor in a full screen modal
void showUJobRichTextEditor({
  required BuildContext context,
  required String title,
  required String initialValue,
  required ValueChanged<String> onSave,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => UJobRichTextEditor(
        title: title,
        initialValue: initialValue,
        onSave: onSave,
      ),
      fullscreenDialog: true,
    ),
  );
}

/// Helper to get plain text preview from json delta
String getPlainTextFromQuillJson(String jsonStr) {
  if (jsonStr.isEmpty) return '';
  try {
    final doc = Document.fromJson(jsonDecode(jsonStr));
    return doc.toPlainText().trim();
  } catch (e) {
    if (jsonStr.contains('<') && jsonStr.contains('>')) {
      try {
        final delta = HtmlToDelta().convert(jsonStr);
        return Document.fromDelta(delta).toPlainText().trim();
      } catch (_) {}
    }
    return jsonStr;
  }
}
