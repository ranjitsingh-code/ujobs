import re

with open('lib/core/router/app_router.dart', 'r') as f:
    content = f.read()

orig_route = """      GoRoute(
        path: '/privacy-policy',
        builder: (_, _) => const LegalPageScreen(type: LegalPageType.privacy),
      ),"""
new_route = """      GoRoute(
        path: '/privacy-policy',
        builder: (_, _) => const LegalPageScreen(type: LegalPageType.privacy),
      ),
      GoRoute(
        path: '/about-us',
        builder: (_, _) => const LegalPageScreen(type: LegalPageType.about),
      ),"""
content = content.replace(orig_route, new_route)

with open('lib/core/router/app_router.dart', 'w') as f:
    f.write(content)
