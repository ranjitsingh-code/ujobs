with open('lib/features/employer/applicants/employer_applicant_provider.dart', 'r') as f:
    text = f.read()

text = text.replace("id: 'a1',", "id: 'a1',\n    avatarUrl: 'https://i.pravatar.cc/150?u=alice',")
text = text.replace("id: 'a2',", "id: 'a2',\n    avatarUrl: 'https://i.pravatar.cc/150?u=bob',")
text = text.replace("id: 'a3',", "id: 'a3',\n    avatarUrl: 'https://i.pravatar.cc/150?u=charlie',")
text = text.replace("id: 'a4',", "id: 'a4',\n    avatarUrl: 'https://i.pravatar.cc/150?u=diana',")
text = text.replace("id: 'a5',", "id: 'a5',\n    avatarUrl: 'https://i.pravatar.cc/150?u=evan',")

with open('lib/features/employer/applicants/employer_applicant_provider.dart', 'w') as f:
    f.write(text)
