import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ujob_empty.dart';
import '../../../core/widgets/ujob_app_bar.dart';

// TODO: implement GET /employer/jobs/{id}/applicants
// ⚠️ NO global /employer/applications endpoint — returns 404
// Must fetch per-job: select a job first, then view its applicants
class ApplicantsScreen extends StatelessWidget {
  const ApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const UJobAppBar(title: 'Applicants'),
    body: const UJobEmpty(
      title: 'Select a job first',
      subtitle: 'Go to My Jobs → tap a job → View Applicants',
      icon: HugeIcons.strokeRoundedUserGroup,
    ),
  );
}
