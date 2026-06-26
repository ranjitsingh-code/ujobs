import json

def add_keys(file_path, keys):
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    for k, v in keys.items():
        if k not in data:
            data[k] = v
            
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write('\n')

keys_en = {
    "salary": "Salary",
    "jobType": "Job Type",
    "workplace": "Workplace",
    "notSpecified": "Not specified"
}

keys_ar = {
    "salary": "الراتب",
    "jobType": "نوع الوظيفة",
    "workplace": "مكان العمل",
    "notSpecified": "غير محدد"
}

add_keys('lib/l10n/app_en.arb', keys_en)
add_keys('lib/l10n/app_ar.arb', keys_ar)
