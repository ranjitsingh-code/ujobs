with open('lib/features/shared/chat/chat_screen.dart', 'r') as f:
    lines = f.readlines()

with open('lib/features/shared/chat/chat_screen.dart', 'w') as f:
    for line in lines:
        if "import '../../../core/widgets/ujob_pdf_viewer_screen.dart';" in line: continue
        if "import '../../../core/widgets/ujob_snack_bar.dart';" in line: continue
        if "import '../../employer/applicants/applicant_detail_screen.dart';" in line: continue
        f.write(line)
