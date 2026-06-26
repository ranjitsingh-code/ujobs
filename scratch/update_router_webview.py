import re

with open('lib/core/router/app_router.dart', 'r') as f:
    content = f.read()

# Add import
if "import '../../features/shared/webview/webview_screen.dart';" not in content:
    content = content.replace("import '../../features/shared/settings/settings_screen.dart';", "import '../../features/shared/settings/settings_screen.dart';\nimport '../../features/shared/webview/webview_screen.dart';")

# Add route
route_block = """      ),
    ],
  );"""
new_route_block = """      ),
      GoRoute(
        path: '/webview',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return WebViewScreen(
            title: extra['title'] as String? ?? '',
            url: extra['url'] as String? ?? '',
          );
        },
      ),
    ],
  );"""

content = content.replace(route_block, new_route_block)

with open('lib/core/router/app_router.dart', 'w') as f:
    f.write(content)
