import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/app_colors.dart';
import 'ujob_error.dart';

class UJobWebView extends StatefulWidget {
  final String url;
  final String errorMessage;

  const UJobWebView({required this.url, required this.errorMessage, super.key});

  @override
  State<UJobWebView> createState() => _UJobWebViewState();
}

class _UJobWebViewState extends State<UJobWebView> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.surface)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => _setLoading(),
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _progress = 100);
          },
          onWebResourceError: (error) {
            if ((error.isForMainFrame ?? true) && mounted) {
              setState(() => _hasError = true);
            }
          },
        ),
      );
    _load();
  }

  @override
  void didUpdateWidget(covariant UJobWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _load();
  }

  void _setLoading() {
    if (mounted) {
      setState(() {
        _progress = 0;
        _hasError = false;
      });
    }
  }

  Future<void> _load() async {
    _setLoading();
    await _controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return UJobError(message: widget.errorMessage, onRetry: _load);
    }

    return Stack(
      children: [
        Positioned.fill(child: WebViewWidget(controller: _controller)),
        if (_progress < 100)
          LinearProgressIndicator(
            value: _progress == 0 ? null : _progress / 100,
            minHeight: 3.h,
            color: AppColors.primary,
            backgroundColor: AppColors.primaryCloud,
          ),
      ],
    );
  }
}
