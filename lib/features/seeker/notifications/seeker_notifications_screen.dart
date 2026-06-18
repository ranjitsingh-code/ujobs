import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_empty.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_loading.dart';

class _Notif {
  final int id;
  final String title;
  final String? body;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  const _Notif({
    required this.id,
    required this.title,
    this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory _Notif.fromJson(Map<String, dynamic> j) => _Notif(
        id: j['id'] as int? ?? 0,
        title: j['title'] as String? ?? j['message'] as String? ?? '',
        body: j['body'] as String? ?? j['subtitle'] as String?,
        type: j['type'] as String? ?? 'system',
        isRead: j['is_read'] as bool? ?? j['read'] as bool? ?? false,
        createdAt: DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}

final _seekerNotifsProvider = FutureProvider.autoDispose<List<_Notif>>((ref) async {
  final res = await ref.watch(dioClientProvider).dio.get(Ep.seekerNotifications);
  final data = res.data['data'] as List? ?? [];
  return data.map((j) => _Notif.fromJson(j as Map<String, dynamic>)).toList();
});

class SeekerNotificationsScreen extends ConsumerStatefulWidget {
  const SeekerNotificationsScreen({super.key});

  @override
  ConsumerState<SeekerNotificationsScreen> createState() => _SeekerNotifsState();
}

class _SeekerNotifsState extends ConsumerState<SeekerNotificationsScreen> {
  String _filter = 'all';

  static const _tabs   = ['all', 'application', 'job', 'system'];
  static const _labels = ['All', 'Applications', 'Jobs', 'System'];

  Color _borderColor(String type) => switch (type) {
    'application' => AppColors.success,
    'job'         => AppColors.primary,
    'system'      => AppColors.purple,
    _             => AppColors.warning,
  };

  Future<void> _markAllRead(List<_Notif> notifs) async {
    try {
      final client = ref.read(dioClientProvider);
      await Future.wait(
        notifs.where((n) => !n.isRead).map((n) => client.dio.post(Ep.seekNotifRead(n.id.toString()))),
      );
      ref.invalidate(_seekerNotifsProvider);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_seekerNotifsProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              final notifs = async.valueOrNull;
              if (notifs != null) _markAllRead(notifs);
            },
            child: Text('Mark all read', style: AppText.label.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      body: Column(children: [
        _FilterBar(
          tabs: _tabs,
          labels: _labels,
          selected: _filter,
          activeColor: AppColors.primary,
          onSelect: (v) => setState(() => _filter = v),
        ),
        Expanded(
          child: async.when(
            loading: () => const UJobLoading(count: 5),
            error: (e, _) => UJobError(
              message: 'Failed to load notifications',
              onRetry: () => ref.refresh(_seekerNotifsProvider),
            ),
            data: (notifs) {
              final list = _filter == 'all'
                  ? notifs
                  : notifs.where((n) => n.type == _filter).toList();
              if (list.isEmpty) {
                return const UJobEmpty(
                  title: 'No notifications',
                  subtitle: 'You\'re all caught up!',
                  icon: HugeIcons.strokeRoundedNotification01,
                );
              }
              return ListView.separated(
                padding: AppSpacing.pagePad,
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final n = list[i];
                  return _NotifTile(
                    title: n.title,
                    body: n.body,
                    time: timeago.format(n.createdAt),
                    isRead: n.isRead,
                    borderColor: _borderColor(n.type),
                    onTap: () async {
                      if (!n.isRead) {
                        try {
                          await ref.read(dioClientProvider).dio.post(Ep.seekNotifRead(n.id.toString()));
                          ref.invalidate(_seekerNotifsProvider);
                        } catch (_) {}
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final List<String> tabs;
  final List<String> labels;
  final String selected;
  final Color activeColor;
  final ValueChanged<String> onSelect;

  const _FilterBar({
    required this.tabs,
    required this.labels,
    required this.selected,
    required this.activeColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          itemCount: tabs.length,
          itemBuilder: (_, i) {
            final sel = selected == tabs[i];
            return GestureDetector(
              onTap: () => onSelect(tabs[i]),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: sel ? activeColor : AppColors.borderLight,
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  labels[i],
                  style: AppText.label.copyWith(color: sel ? AppColors.white : AppColors.muted),
                ),
              ),
            );
          },
        ),
      );
}

class _NotifTile extends StatelessWidget {
  final String title;
  final String? body;
  final String time;
  final bool isRead;
  final Color borderColor;
  final VoidCallback onTap;

  const _NotifTile({
    required this.title,
    this.body,
    required this.time,
    required this.isRead,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead ? AppColors.surface : AppColors.primary.withValues(alpha: 0.04),
            borderRadius: AppRadius.md,
            border: Border(left: BorderSide(color: borderColor, width: 3)),
            boxShadow: AppShadow.card(),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              title,
              style: AppText.bodyBold.copyWith(
                fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
              ),
            ),
            if (body != null) ...[
              const SizedBox(height: 2),
              Text(body!, style: AppText.small.copyWith(color: AppColors.muted)),
            ],
            const SizedBox(height: 4),
            Text(time, style: AppText.caption.copyWith(color: AppColors.muted2)),
          ]),
        ),
      );
}
