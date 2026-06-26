import re

with open('lib/features/shared/notifications/notifications_provider.dart', 'r') as f:
    text = f.read()

text = text.replace(
    """        state = AsyncData(state.value!.copyWith(notifications: notifications));
      }
    } catch (e) {""",
    """        state = AsyncData(state.value!.copyWith(notifications: notifications));
        ref.invalidate(unreadNotificationCountProvider);
      }
    } catch (e) {"""
)

with open('lib/features/shared/notifications/notifications_provider.dart', 'w') as f:
    f.write(text)

