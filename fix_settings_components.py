import re

with open('lib/features/employer/settings/employer_settings_screen.dart', 'r') as f:
    text = f.read()

pattern = re.compile(r"class _SectionHeader.*", re.DOTALL)

new_components = """class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.bg, // Light gray background for section headers
      padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 12.h),
      child: Text(
        title.toUpperCase(),
        style: AppText.caption.copyWith(
          color: AppColors.muted2,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final Color? textColor;
  final VoidCallback onTap;
  final bool hideDivider;

  const _NavTile({
    required this.label,
    this.subtitle,
    this.textColor,
    required this.onTap,
    this.hideDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: hideDivider ? null : Border(
            bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5), width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppText.body.copyWith(
                      color: textColor ?? AppColors.text,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(subtitle!, style: AppText.caption.copyWith(color: AppColors.muted)),
                  ],
                ],
              ),
            ),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: AppColors.muted2,
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool hideDivider;

  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hideDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: hideDivider ? null : Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppText.body.copyWith(
                color: AppColors.text,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: AppColors.border,
          ),
        ],
      ),
    );
  }
}
"""

text = pattern.sub(new_components, text)

with open('lib/features/employer/settings/employer_settings_screen.dart', 'w') as f:
    f.write(text)
