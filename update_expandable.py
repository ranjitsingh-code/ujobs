with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

# 1. Revert Maximize01 to Edit02 in the About Company field
text = text.replace("HugeIcons.strokeRoundedMaximize01", "HugeIcons.strokeRoundedEdit02")

# 2. Rewrite _SectionCard as an Expandable Stateful Widget
old_section_card = """class _SectionCard extends StatelessWidget {
  final String title;
  final dynamic icon;
  final Widget child;
  final VoidCallback onEdit;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppRadius.md,
                ),
                child: HugeIcon(icon: icon, color: AppColors.primary, size: 20.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(title, style: AppText.heading3.copyWith(color: AppColors.text2)),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: const BoxDecoration(
                    color: AppColors.bg,
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(icon: HugeIcons.strokeRoundedEdit02, color: AppColors.primary, size: 18.r),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}"""

new_section_card = """class _SectionCard extends StatefulWidget {
  final String title;
  final dynamic icon;
  final Widget child;
  final VoidCallback onEdit;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    required this.onEdit,
  });

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: _isExpanded 
                ? BorderRadius.vertical(top: Radius.circular(AppRadius.xl.topLeft.x))
                : AppRadius.xl,
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppRadius.md,
                    ),
                    child: HugeIcon(icon: widget.icon, color: AppColors.primary, size: 20.r),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
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
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(20.r, 0, 20.r, 20.r),
              child: widget.child,
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}"""
text = text.replace(old_section_card, new_section_card)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
