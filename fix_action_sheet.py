import re

with open('lib/core/widgets/ujob_employer_job_actions_sheet.dart', 'r') as f:
    text = f.read()

target = """      onReopen: onReopen == null
          ? null
          : () {
              Navigator.pop(ctx);
              onReopen();
            },
      onDelete: onDelete == null"""

replacement = """      onReopen: onReopen == null
          ? null
          : () {
              Navigator.pop(ctx);
              onReopen();
            },
      onClose: onClose == null
          ? null
          : () {
              Navigator.pop(ctx);
              onClose();
            },
      onDelete: onDelete == null"""

text = text.replace(target, replacement)

with open('lib/core/widgets/ujob_employer_job_actions_sheet.dart', 'w') as f:
    f.write(text)
