import re

with open('lib/features/shared/notifications/notifications_provider.dart', 'r') as f:
    text = f.read()

# Add ref.invalidate inside markAsRead
text = text.replace(
    """        state = AsyncData(state.value!.copyWith(notifications: notifications));
      }
    } catch (e) {""",
    """        state = AsyncData(state.value!.copyWith(notifications: notifications));
        // Force unread count stream to refresh instantly
        ref.invalidate(unreadNotificationCountProvider);
      }
    } catch (e) {"""
)

with open('lib/features/shared/notifications/notifications_provider.dart', 'w') as f:
    f.write(text)

