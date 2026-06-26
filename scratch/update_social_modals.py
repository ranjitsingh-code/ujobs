import re

with open('lib/features/seeker/company/seeker_company_profile_screen.dart', 'r') as f:
    content = f.read()

# Add imports if they don't exist
if 'import \'package:url_launcher/url_launcher.dart\';' not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter/services.dart';\nimport 'package:url_launcher/url_launcher.dart';")


orig_modals = """  void _showSocialsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24.w,
            24.h,
            24.w,
            MediaQuery.of(context).padding.bottom + 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Follow Us', style: AppText.heading2),
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      color: AppColors.text,
                      size: 24.r,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              if (widget.company.linkedinUrl != null) ...[
                _socialRow(
                  HugeIcons.strokeRoundedLinkedin01,
                  'LinkedIn',
                  AppColors.primary,
                  widget.company.linkedinUrl!,
                ),
                SizedBox(height: 16.h),
              ],
              if (widget.company.facebookUrl != null) ...[
                _socialRow(
                  HugeIcons.strokeRoundedFacebook01,
                  'Facebook',
                  const Color(0xFF1877F2),
                  widget.company.facebookUrl!,
                ),
                SizedBox(height: 16.h),
              ],
              if (widget.company.linkedinUrl == null &&
                  widget.company.facebookUrl == null)
                Center(
                  child: Text(
                    'No social links provided.',
                    style: AppText.body.copyWith(color: AppColors.muted),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _socialRow(
    List<List<dynamic>> icon,
    String label,
    Color brandColor,
    String url,
  ) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            HugeIcon(icon: icon, color: brandColor, size: 24.r),
            SizedBox(width: 16.w),
            Expanded(child: Text(label, style: AppText.bodyBold)),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: AppColors.muted,
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }"""

new_modals = """  void _showSocialsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        final hasLinkedIn = widget.company.linkedinUrl != null && widget.company.linkedinUrl!.isNotEmpty;
        final hasFacebook = widget.company.facebookUrl != null && widget.company.facebookUrl!.isNotEmpty;
        final linkedinUrl = hasLinkedIn ? widget.company.linkedinUrl! : 'https://linkedin.com/company/ujobs-demo';
        final facebookUrl = hasFacebook ? widget.company.facebookUrl! : 'https://facebook.com/ujobs-demo';

        return Padding(
          padding: EdgeInsets.fromLTRB(
            24.w,
            24.h,
            24.w,
            MediaQuery.of(context).padding.bottom + 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Follow Us', style: AppText.heading2),
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      color: AppColors.text,
                      size: 24.r,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _socialRow(
                HugeIcons.strokeRoundedLinkedin01,
                'LinkedIn',
                AppColors.primary,
                linkedinUrl,
                context,
              ),
              SizedBox(height: 16.h),
              _socialRow(
                HugeIcons.strokeRoundedFacebook01,
                'Facebook',
                const Color(0xFF1877F2),
                facebookUrl,
                context,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _socialRow(
    List<List<dynamic>> icon,
    String label,
    Color brandColor,
    String url,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              if (context.mounted) {
                UJobToast.error(context, 'Could not launch URL');
              }
            }
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                HugeIcon(icon: icon, color: brandColor, size: 24.r),
                SizedBox(width: 16.w),
                Expanded(child: Text(label, style: AppText.bodyBold)),
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: url));
                    if (context.mounted) {
                      UJobToast.success(context, 'Link copied to clipboard!');
                    }
                  },
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCopy01,
                    color: AppColors.muted,
                    size: 20.r,
                  ),
                  tooltip: 'Copy Link',
                ),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  color: AppColors.muted,
                  size: 20.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }"""

content = content.replace(orig_modals, new_modals)

with open('lib/features/seeker/company/seeker_company_profile_screen.dart', 'w') as f:
    f.write(content)
