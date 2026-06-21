import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_web_view.dart';

enum LegalPageType {
  terms('terms-and-conditions'),
  privacy('privacy-policy');

  const LegalPageType(this.slug);
  final String slug;
}

final _legalPageProvider = FutureProvider.autoDispose.family<String, String>((
  ref,
  slug,
) async {
  final response = await ref
      .read(dioClientProvider)
      .dio
      .get(Ep.publicPage(slug));
  final raw = response.data;
  final value = raw is Map<String, dynamic> ? (raw['data'] ?? raw) : null;
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Invalid legal page response');
  }

  final url = _legalPageUrl(value);
  if (url == null) {
    throw const FormatException('Legal page URL is missing');
  }

  return url;
});

String? _legalPageUrl(Map<String, dynamic> data) {
  for (final key in ['website', 'url', 'page_url', 'link']) {
    final value = data[key]?.toString().trim();
    final uri = value == null ? null : Uri.tryParse(value);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) return value;
  }
  return null;
}

class LegalPageScreen extends ConsumerWidget {
  final LegalPageType type;

  const LegalPageScreen({required this.type, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final fallbackTitle = type == LegalPageType.terms
        ? l10n.termsAndConditions
        : l10n.privacyPolicy;
    final page = ref.watch(_legalPageProvider(type.slug));

    return Scaffold(
      appBar: UJobAppBar(title: fallbackTitle),
      body: page.when(
        loading: () => const UJobLoading(),
        error: (_, _) => UJobError(
          message: l10n.errorLegalPageLoad,
          onRetry: () => ref.invalidate(_legalPageProvider(type.slug)),
        ),
        data: (url) =>
            UJobWebView(url: url, errorMessage: l10n.errorLegalPageLoad),
      ),
    );
  }
}
