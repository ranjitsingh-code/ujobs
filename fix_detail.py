import re

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'r') as f:
    code = f.read()

if "import 'package:url_launcher/url_launcher.dart';" not in code:
    code = code.replace("import 'package:go_router/go_router.dart';", "import 'package:go_router/go_router.dart';\nimport 'package:url_launcher/url_launcher.dart';")

resume_old = """        _buildSectionCard(
          'Resume',
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedPdf01,
                  color: AppColors.error,
                  size: 28.r,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'job_resume_md_azad_hossain_tutul.pdf',
                      style: AppText.bodyBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '1.4 MB',
                      style: AppText.small.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedEye,
                  color: AppColors.primary,
                  size: 24.r,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UJobPdfViewerScreen(
                        title: '${applicant.name} - Resume',
                        pdfUrl:
                            'assets/images/job_resume_md_azad_hossain_tutul.pdf',
                        isAsset: true,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 8.w),
              IconButton(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedDownload04,
                  color: AppColors.primary,
                  size: 24.r,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogCtx) => UJobAlertDialog(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedDownload04,
                        color: AppColors.primary,
                        size: 32.r,
                      ),
                      iconBgColor: AppColors.primary,
                      confirmColor: AppColors.primary,
                      title: 'Download Resume',
                      description:
                          'Do you want to download this resume to your device?',
                      confirmText: 'Download',
                      onConfirm: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(dialogCtx);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Downloading resume...',
                              style: AppText.body.copyWith(color: Colors.white),
                            ),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        try {
                          final byteData = await rootBundle.load(
                            'assets/images/job_resume_md_azad_hossain_tutul.pdf',
                          );
                          final directory =
                              await getApplicationDocumentsDirectory();
                          final file = File(
                            '${directory.path}/job_resume_md_azad_hossain_tutul.pdf',
                          );
                          await file.writeAsBytes(
                            byteData.buffer.asUint8List(
                              byteData.offsetInBytes,
                              byteData.lengthInBytes,
                            ),
                          );
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Resume successfully downloaded to your device!',
                                style: AppText.body.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to download resume.',
                                style: AppText.body.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),"""

resume_new = """        if (applicant.resumeUrl != null)
          _buildSectionCard(
            'Resume',
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedPdf01,
                    color: AppColors.error,
                    size: 28.r,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applicant.resumeUrl!.split('/').last,
                        style: AppText.bodyBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'PDF Document',
                        style: AppText.small.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedEye,
                    color: AppColors.primary,
                    size: 24.r,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UJobPdfViewerScreen(
                          title: '${applicant.name} - Resume',
                          pdfUrl: applicant.resumeUrl!,
                          isAsset: false,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(width: 8.w),
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedDownload04,
                    color: AppColors.primary,
                    size: 24.r,
                  ),
                  onPressed: () async {
                    final url = Uri.parse(applicant.resumeUrl!);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Could not launch download URL.',
                            style: AppText.body.copyWith(color: Colors.white),
                          ),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        if (applicant.resumeUrl != null) SizedBox(height: 24.h),"""

code = code.replace(resume_old, resume_new)

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'w') as f:
    f.write(code)
