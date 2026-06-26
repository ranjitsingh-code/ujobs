import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Style;
import 'package:flutter_html/flutter_html.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobRichTextDisplay extends StatefulWidget {
  final String content;

  const UJobRichTextDisplay({required this.content, super.key});

  @override
  State<UJobRichTextDisplay> createState() => _UJobRichTextDisplayState();
}

class _UJobRichTextDisplayState extends State<UJobRichTextDisplay> {
  late QuillController _controller;
  bool _isRawText = false;
  bool _isHtml = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant UJobRichTextDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _initController();
    }
  }

  void _initController() {
    Document doc;
    if (widget.content.isEmpty) {
      doc = Document();
    } else {
      // Check if content is HTML
      if (RegExp(r'<[a-z][\s\S]*>').hasMatch(widget.content)) {
        _isHtml = true;
        _isRawText = false;
        doc = Document();
      } else {
        try {
          doc = Document.fromJson(jsonDecode(widget.content));
          _isRawText = false;
          _isHtml = false;
        } catch (e) {
          doc = Document()..insert(0, widget.content);
          _isRawText = true;
          _isHtml = false;
        }
      }
    }
    _controller = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isHtml) {
      return Html(
        data: widget.content,
        style: {
          "body": Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(14),
            color: AppColors.text2,
          ),
          "p": Style(margin: Margins.only(bottom: 8)),
          "ul": Style(margin: Margins.only(left: -20, bottom: 8)),
          "li": Style(margin: Margins.only(bottom: 4)),
        },
      );
    }

    if (_isRawText) {
      return Text(
        widget.content,
        style: AppText.bodyMedium.copyWith(color: AppColors.text2),
      );
    }

    return DefaultTextStyle(
      style: AppText.bodyMedium.copyWith(color: AppColors.muted2),
      child: QuillEditor.basic(
        controller: _controller,
        config: const QuillEditorConfig(showCursor: false, scrollable: false),
      ),
    );
  }
}
