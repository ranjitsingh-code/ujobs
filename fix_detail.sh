#!/bin/bash
sed -i '' 's/final String applicantId;/final Applicant applicant;/g' lib/features/employer/applicants/applicant_detail_screen.dart
sed -i '' 's/required this.applicantId/required this.applicant/g' lib/features/employer/applicants/applicant_detail_screen.dart
sed -i '' 's/final applicants = ref.watch(employerApplicantsProvider);//g' lib/features/employer/applicants/applicant_detail_screen.dart
sed -i '' 's/final applicant = applicants.firstWhere(//g' lib/features/employer/applicants/applicant_detail_screen.dart
sed -i '' 's/(a) => a.id == widget.applicantId,//g' lib/features/employer/applicants/applicant_detail_screen.dart
sed -i '' 's/orElse: () => applicants.first,//g' lib/features/employer/applicants/applicant_detail_screen.dart
sed -i '' 's/);/final applicant = widget.applicant;/g' lib/features/employer/applicants/applicant_detail_screen.dart
