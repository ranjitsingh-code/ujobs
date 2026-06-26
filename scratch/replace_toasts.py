import os
import glob

files = glob.glob('lib/features/seeker/**/*.dart', recursive=True)

for file in files:
    with open(file, 'r') as f:
        content = f.read()
    
    if "'Job removed from saved' : 'Job saved successfully!'" in content:
        content = content.replace("'Job removed from saved' : 'Job saved successfully!'", "'unsaved' : 'This has been saved'")
        with open(file, 'w') as f:
            f.write(content)
