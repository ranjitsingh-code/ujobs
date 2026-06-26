import re

with open('lib/core/widgets/ujob_employer_job_card.dart', 'r') as f:
    code = f.read()

code = code.replace("final VoidCallback? onDelete;", "final VoidCallback? onClose;\n  final VoidCallback? onDelete;")
code = code.replace("this.onDelete,", "this.onClose,\n    this.onDelete,")

delete_block = """                      if (onDelete != null)
                        PopupMenuItem(
                          value: 'delete',
                          child: _PopupItem(
                            icon: HugeIcons.strokeRoundedDelete01,
                            label: l10n.delete,
                            color: AppColors.error,
                            onTap: onDelete!,
                          ),
                        ),"""

close_block = """                      if (onClose != null)
                        PopupMenuItem(
                          value: 'close',
                          child: _PopupItem(
                            icon: HugeIcons.strokeRoundedAlert02,
                            label: 'Close Job',
                            color: AppColors.text,
                            onTap: onClose!,
                          ),
                        ),
                      if (onDelete != null)
                        PopupMenuItem(
                          value: 'delete',
                          child: _PopupItem(
                            icon: HugeIcons.strokeRoundedDelete01,
                            label: l10n.delete,
                            color: AppColors.error,
                            onTap: onDelete!,
                          ),
                        ),"""

code = code.replace(delete_block, close_block)
with open('lib/core/widgets/ujob_employer_job_card.dart', 'w') as f:
    f.write(code)


with open('lib/core/widgets/ujob_employer_job_actions_sheet.dart', 'r') as f:
    code2 = f.read()

code2 = code2.replace("VoidCallback? onDelete,", "VoidCallback? onClose, VoidCallback? onDelete,")
code2 = code2.replace("onDelete: onDelete == null\n          ? null\n          : () {\n              Navigator.pop(context);\n              onDelete();\n            },", 
                      "onClose: onClose == null ? null : () { Navigator.pop(context); onClose(); },\n      onDelete: onDelete == null ? null : () { Navigator.pop(context); onDelete(); },")

code2 = code2.replace("final VoidCallback? onDelete;", "final VoidCallback? onClose;\n  final VoidCallback? onDelete;")
code2 = code2.replace("this.onDelete,", "this.onClose,\n    this.onDelete,")

delete_block_sheet = """        if (onDelete != null)
          _ActionTile(
            icon: HugeIcons.strokeRoundedDelete01,
            label: l10n.delete,
            color: AppColors.error,
            onTap: onDelete!,
          ),"""

close_block_sheet = """        if (onClose != null)
          _ActionTile(
            icon: HugeIcons.strokeRoundedAlert02,
            label: 'Close Job',
            color: AppColors.text,
            onTap: onClose!,
          ),
        if (onDelete != null)
          _ActionTile(
            icon: HugeIcons.strokeRoundedDelete01,
            label: l10n.delete,
            color: AppColors.error,
            onTap: onDelete!,
          ),"""
code2 = code2.replace(delete_block_sheet, close_block_sheet)

with open('lib/core/widgets/ujob_employer_job_actions_sheet.dart', 'w') as f:
    f.write(code2)

