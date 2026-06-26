import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ujob_app_bar.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'providers/audit_log_provider.dart';
import '../../../../core/models/audit_log_entry.dart';

class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  int _currentPage = 1;
  final List<AuditLogEntry> _logs = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    
    setState(() => _isLoadingMore = true);
    
    try {
      final nextLogs = await ref.read(auditLogProvider(_currentPage + 1).future);
      if (mounted) {
        setState(() {
          _currentPage++;
          if (nextLogs.isEmpty) {
            _hasMore = false;
          } else {
            _logs.addAll(nextLogs);
          }
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    final asyncLogs = ref.watch(auditLogProvider(1));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UJobAppBar(
        title: l10n.auditLog,
        showBack: true,
        backgroundColor: AppColors.background,
      ),
      body: asyncLogs.when(
        data: (initialLogs) {
          // Initialize list on first load
          if (_currentPage == 1 && _logs.isEmpty) {
            _logs.addAll(initialLogs);
            if (initialLogs.isEmpty) _hasMore = false;
          }

          if (_logs.isEmpty) {
            return Center(
              child: Text(
                l10n.noAuditLogs,
                style: AppText.body.copyWith(color: AppColors.muted),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              setState(() {
                _currentPage = 1;
                _logs.clear();
                _hasMore = true;
              });
              ref.invalidate(auditLogProvider);
            },
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              itemCount: _logs.length + (_hasMore ? 1 : 0),
              separatorBuilder: (_, __) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                if (index == _logs.length) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }
                
                final log = _logs[index];
                return _AuditLogCard(log: log);
              },
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Text(
            l10n.error,
            style: AppText.body.copyWith(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

class _AuditLogCard extends StatelessWidget {
  final AuditLogEntry log;

  const _AuditLogCard({required this.log});

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    // Capitalize action
    final actionText = log.action.isEmpty 
        ? 'Unknown' 
        : '${log.action[0].toUpperCase()}${log.action.substring(1)}';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedShield01,
                  color: AppColors.primary,
                  size: 20.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      actionText,
                      style: AppText.bodyBold.copyWith(color: AppColors.text),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatDate(log.createdAt),
                      style: AppText.small.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (log.ipAddress != null || log.userAgent != null) ...[
            SizedBox(height: 16.h),
            Divider(color: AppColors.borderLight, height: 1),
            SizedBox(height: 12.h),
            if (log.ipAddress != null) ...[
              _InfoRow(
                icon: HugeIcons.strokeRoundedGlobal,
                label: l10n.ipAddress,
                value: log.ipAddress!,
              ),
              if (log.userAgent != null) SizedBox(height: 8.h),
            ],
            if (log.userAgent != null) ...[
              _InfoRow(
                icon: HugeIcons.strokeRoundedLaptopProgramming,
                label: l10n.deviceBrowser,
                value: log.userAgent!,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final dynamic icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HugeIcon(
          icon: icon,
          color: AppColors.muted,
          size: 16.r,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppText.small.copyWith(color: AppColors.muted),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: AppText.body.copyWith(
                  color: AppColors.text,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
