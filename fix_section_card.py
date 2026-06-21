import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

# 1. Update _SectionCard class
old_section_card = """class _SectionCard extends StatefulWidget {
  final String title;
  final dynamic icon;
  final Widget child;
  final VoidCallback onEdit;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    required this.onEdit,
  });"""

new_section_card = """class _SectionCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final dynamic icon;
  final Widget child;
  final VoidCallback onEdit;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
    required this.onEdit,
  });"""

text = text.replace(old_section_card, new_section_card)

# 2. Update _SectionCardState build method
old_section_row = """                  Expanded(
                    child: Text(widget.title, style: AppText.heading3.copyWith(color: AppColors.text2)),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.muted,
                      size: 24.r,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: widget.onEdit,
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: const BoxDecoration(
                        color: AppColors.bg,
                        shape: BoxShape.circle,
                      ),
                      child: HugeIcon(icon: HugeIcons.strokeRoundedEdit02, color: AppColors.primary, size: 18.r),
                    ),
                  ),"""

new_section_row = """                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.title, style: AppText.bodyBold.copyWith(color: AppColors.text2)),
                        if (!_isExpanded && widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            widget.subtitle!,
                            style: AppText.caption.copyWith(color: AppColors.muted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ] else if (!_isExpanded) ...[
                          SizedBox(height: 2.h),
                          Text(
                            'Not set',
                            style: AppText.caption.copyWith(color: AppColors.muted2, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: widget.onEdit,
                    icon: HugeIcon(icon: HugeIcons.strokeRoundedEdit02, color: AppColors.primary, size: 14.r),
                    label: Text('Edit', style: AppText.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.125 : 0.0, // Rotates + to x
                    duration: const Duration(milliseconds: 300),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedAdd01,
                      color: AppColors.muted,
                      size: 20.r,
                    ),
                  ),"""

text = text.replace(old_section_row, new_section_row)

# 3. Add subtitles to instances of _SectionCard
def build_subtitle_logic():
    return [
        (
            "_SectionCard(\n                    title: 'Company Information',",
            """_SectionCard(
                    title: 'Company Information',
                    subtitle: [company.name, company.industry, company.website].where((e) => e != null && e.isNotEmpty).join(' · '),"""
        ),
        (
            "_SectionCard(\n                    title: 'Hiring Information',",
            """_SectionCard(
                    title: 'Hiring Information',
                    subtitle: [company.size, company.workType].where((e) => e != null && e.isNotEmpty).join(' · '),"""
        ),
        (
            "_SectionCard(\n                    title: 'Location',",
            """_SectionCard(
                    title: 'Location',
                    subtitle: [company.city, company.country].where((e) => e != null && e.isNotEmpty).join(' · '),"""
        ),
        (
            "_SectionCard(\n                    title: 'Contact Information',",
            """_SectionCard(
                    title: 'Contact Information',
                    subtitle: [company.contactPersonName, company.contactEmail].where((e) => e != null && e.isNotEmpty).join(' · '),"""
        ),
        (
            "_SectionCard(\n                    title: 'Social Links',",
            """_SectionCard(
                    title: 'Social Links',
                    subtitle: [
                      if (company.linkedInUrl != null && company.linkedInUrl!.isNotEmpty) 'LinkedIn',
                      if (company.facebookUrl != null && company.facebookUrl!.isNotEmpty) 'Facebook',
                    ].join(' · '),"""
        )
    ]

for old, new in build_subtitle_logic():
    text = text.replace(old, new)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
