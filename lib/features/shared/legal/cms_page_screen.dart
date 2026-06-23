import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_web_view.dart';
import '../../../core/providers/cms_provider.dart';

class CmsPageScreen extends ConsumerWidget {
  final String slug;

  const CmsPageScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(cmsPageDetailProvider(slug));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: UJobAppBar(
        title: pageAsync.valueOrNull?.title ?? '',
        showBack: true,
      ),
      body: pageAsync.when(
        data: (page) => page.body != null 
            ? UJobWebView(
                htmlContent: page.body!,
                errorMessage: 'Failed to render page.',
              )
            : Center(child: Text('No content available.', style: AppText.body)),
        loading: () => const UJobLoading(count: 1),
        error: (err, stack) => UJobError(
          message: 'Failed to load page',
          onRetry: () => ref.refresh(cmsPageDetailProvider(slug)),
        ),
      ),
    );
  }
}
