import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UJobPillTabBar extends StatefulWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final EdgeInsetsGeometry padding;
  final bool isExpanded;

  const UJobPillTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.padding = EdgeInsets.zero,
    this.isExpanded = false,
  });

  @override
  State<UJobPillTabBar> createState() => _UJobPillTabBarState();
}

class _UJobPillTabBarState extends State<UJobPillTabBar> {
  late final ScrollController _scrollController;
  late final List<GlobalKey> _keys;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _keys = List.generate(widget.tabs.length, (_) => GlobalKey());
    _revealTab(widget.selectedIndex, animate: false);
  }

  @override
  void didUpdateWidget(covariant UJobPillTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _keys.clear();
      _keys.addAll(List.generate(widget.tabs.length, (_) => GlobalKey()));
    }
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _revealTab(widget.selectedIndex);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _revealTab(int index, {bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || index < 0 || index >= _keys.length) return;
      final context = _keys[index].currentContext;
      if (context == null) return;
      
      if (!_scrollController.hasClients) return;

      if (animate) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.5,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
        );
      } else {
        Scrollable.ensureVisible(
          context,
          alignment: 0.5,
          duration: Duration.zero,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rowChildren = widget.tabs.asMap().entries.map((entry) {
      final index = entry.key;
      final label = entry.value;
      final isSelected = widget.selectedIndex == index;
      final child = Padding(
        key: _keys[index],
        padding: EdgeInsetsDirectional.only(
          end: index == widget.tabs.length - 1 ? 0 : 8.w,
        ),
        child: InkWell(
          onTap: () {
            widget.onTabSelected(index);
            _revealTab(index);
          },
          borderRadius: AppRadius.pill,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 9.h,
            ),
            alignment: widget.isExpanded ? Alignment.center : null,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.surface,
              borderRadius: AppRadius.pill,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.border,
              ),
              boxShadow: isSelected ? AppShadow.card() : null,
            ),
            child: Text(
              label,
              style: AppText.label.copyWith(
                color: isSelected
                    ? AppColors.surface
                    : AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
      return widget.isExpanded ? Expanded(child: child) : child;
    }).toList();

    return SizedBox(
      width: double.infinity,
      child: widget.isExpanded
          ? Padding(padding: widget.padding, child: Row(children: rowChildren))
          : SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: widget.padding,
              child: Row(children: rowChildren),
            ),
    );
  }
}
