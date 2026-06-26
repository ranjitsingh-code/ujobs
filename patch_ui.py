import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

section_card_code = """
class _SectionCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final dynamic icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(_isExpanded ? 0.08 : 0.02),
            blurRadius: _isExpanded ? 24 : 10,
            offset: Offset(0, _isExpanded ? 8 : 4),
          ),
        ],
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
                ? BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xl.topLeft.x),
                  )
                : AppRadius.xl,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20.r,
                20.r,
                20.r,
                _isExpanded ? 0 : 20.r,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppRadius.md,
                    ),
                    child: HugeIcon(
                      icon: widget.icon,
                      color: AppColors.primary,
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: AppText.bodyBold.copyWith(
                            color: AppColors.text2,
                          ),
                        ),
                        if (!_isExpanded &&
                            widget.subtitle != null &&
                            widget.subtitle!.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            widget.subtitle!,
                            style: AppText.caption.copyWith(
                              color: AppColors.muted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ] else if (!_isExpanded) ...[
                          SizedBox(height: 2.h),
                          Text(
                            'Not set',
                            style: AppText.caption.copyWith(
                              color: AppColors.muted2,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
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
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(20.r, 20.r, 20.r, 20.r),
              child: widget.child,
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
"""

# Replace _buildSection method with _SectionCard class
content = re.sub(
    r"Widget _buildSection\(\{.*?\}\) \{.*?\n  \}",
    "",
    content,
    flags=re.DOTALL
)

# Append the new class
content += "\n" + section_card_code

# Replace usage of _buildSection with _SectionCard
content = content.replace("_buildSection(", "_SectionCard(")
content = content.replace('title: "Location",', 'title: "Location", subtitle: "${_cityController.text}",')
content = content.replace('title: "Contact Person",', 'title: "Hiring Information", subtitle: "Contact Details",')
content = content.replace('title: "Other Details",', 'title: "Other Details", subtitle: "Size & Work Type",')

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)

