import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_web_view.dart';

class WebViewScreen extends StatelessWidget {
  final String title;
  final String url;

  const WebViewScreen({
    required this.title,
    required this.url,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: UJobAppBar(
        title: title,
        showBack: true,
      ),
      body: UJobWebView(
        url: url,
        errorMessage: 'Failed to load page.',
      ),
    );
  }
}
