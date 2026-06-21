with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

# Restore size: company.size in _showEditDescription
start_idx = text.find('_showEditDescription')
if start_idx != -1:
    end_idx = text.find('}', start_idx)
    # The last occurrence of sizeCtrl.text in this block is what we want to change
    block = text[start_idx:]
    block = block.replace('size: sizeCtrl.text,', 'size: company.size,', 1)
    text = text[:start_idx] + block

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
