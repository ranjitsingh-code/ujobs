import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../features/shared/chat/conversation_provider.dart';
import 'ujob_section_header.dart';

class UJobMessagesToReply extends StatelessWidget {
  final List<Conversation> conversations;
  final VoidCallback onViewAll;

  const UJobMessagesToReply({
    required this.conversations,
    required this.onViewAll,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UJobSectionHeader(
          title: 'Needs Reply',
          actionLabel: 'View all',
          onActionTap: onViewAll,
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 78.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: conversations.length,
            separatorBuilder: (_, _) => SizedBox(width: 16.w),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return _MessageAvatar(conversation: conversation);
            },
          ),
        ),
      ],
    );
  }
}

class _MessageAvatar extends StatelessWidget {
  final Conversation conversation;

  const _MessageAvatar({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final initials =
        conversation.otherInitials ??
        (conversation.otherName.isNotEmpty ? conversation.otherName[0] : '?');

    return Semantics(
      button: true,
      label: conversation.unreadCount > 0
          ? '${conversation.otherName}, ${conversation.unreadCount} unread messages'
          : '${conversation.otherName}, awaiting reply',
      child: InkWell(
        onTap: () {
          if (conversation.id.startsWith('demo-')) {
            // Contextually check route location to go to appropriate messages tab
            final currentLoc = GoRouterState.of(context).matchedLocation;
            if (currentLoc.startsWith('/employer')) {
              context.go('/employer/messages');
            } else {
              context.go('/seeker/messages');
            }
            return;
          }
          context.push(
            '/conversations/${conversation.id}',
            extra: {
              'name': conversation.otherName,
              'initials': conversation.otherInitials,
              'avatar': conversation.otherAvatar,
            },
          );
        },
        borderRadius: BorderRadius.circular(28.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: AppColors.borderLight,
                  backgroundImage: conversation.otherAvatar != null
                      ? NetworkImage(conversation.otherAvatar!)
                      : null,
                  child: conversation.otherAvatar == null
                      ? Text(
                          initials,
                          style: AppText.bodyBold.copyWith(
                            color: AppColors.text2,
                          ),
                        )
                      : null,
                ),
                if (conversation.unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        conversation.unreadCount.toString(),
                        style: AppText.caption.copyWith(
                          color: AppColors.surface,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: 56.r,
              child: Text(
                conversation.otherName,
                style: AppText.caption,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
