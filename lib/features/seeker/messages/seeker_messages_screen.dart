import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ujob_avatar.dart';
import '../../../core/widgets/ujob_empty.dart';
import '../../../core/widgets/ujob_error.dart';
import '../../../core/widgets/ujob_loading.dart';
import '../../../core/widgets/ujob_app_bar.dart';
import '../../shared/chat/conversation_provider.dart';

// Seekers can only reply — cannot initiate conversations (403 on POST /conversations)
class SeekerMessagesScreen extends ConsumerStatefulWidget {
  const SeekerMessagesScreen({super.key});

  @override
  ConsumerState<SeekerMessagesScreen> createState() => _SeekerMessagesState();
}

class _SeekerMessagesState extends ConsumerState<SeekerMessagesScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(conversationsProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const UJobAppBar(title: 'Messages', showBack: false),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v.toLowerCase()),
            style: AppText.body,
            decoration: InputDecoration(
              hintText: 'Search conversations...',
              hintStyle: AppText.body.copyWith(color: AppColors.muted2),
              prefixIcon: const HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: AppColors.muted2, size: 20),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: AppRadius.xl, borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: async.when(
            loading: () => const UJobLoading(count: 5),
            error: (e, _) => UJobError(
              message: 'Failed to load messages',
              onRetry: () => ref.refresh(conversationsProvider),
            ),
            data: (convs) {
              final list = _query.isEmpty
                  ? convs
                  : convs.where((c) => c.otherName.toLowerCase().contains(_query)).toList();
              if (list.isEmpty) {
                return const UJobEmpty(
                  title: 'No messages yet',
                  subtitle: 'Employers will reach out here after reviewing your application',
                  icon: HugeIcons.strokeRoundedBubbleChat,
                );
              }
              return ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, _) => const Divider(height: 1, indent: 76),
                itemBuilder: (_, i) => _ConvTile(conv: list[i]),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _ConvTile extends StatelessWidget {
  final Conversation conv;
  const _ConvTile({required this.conv});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => context.push(
          '/conversations/${conv.id}',
          extra: {'name': conv.otherName, 'initials': conv.otherInitials, 'avatar': conv.otherAvatar},
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(children: [
            Stack(children: [
              UJobAvatar(
                imageUrl: conv.otherAvatar,
                initials: conv.otherInitials ?? conv.otherName[0],
                size: 48,
              ),
              if (conv.otherOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
            ]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(conv.otherName, style: AppText.bodyBold),
                const SizedBox(height: 2),
                Text(
                  conv.lastMessage ?? 'No messages yet',
                  style: AppText.small.copyWith(color: AppColors.muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              if (conv.lastAt != null)
                Text(
                  timeago.format(conv.lastAt!, allowFromNow: true),
                  style: AppText.caption.copyWith(color: AppColors.muted2),
                ),
              const SizedBox(height: 4),
              if (conv.unreadCount > 0)
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      conv.unreadCount > 9 ? '9+' : conv.unreadCount.toString(),
                      style: AppText.caption.copyWith(color: AppColors.white, fontSize: 10),
                    ),
                  ),
                ),
            ]),
          ]),
        ),
      );
}
