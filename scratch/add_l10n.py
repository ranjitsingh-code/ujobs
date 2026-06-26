import json

en_file = 'lib/l10n/app_en.arb'
ar_file = 'lib/l10n/app_ar.arb'

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
    "companyProfile": "Company Profile",
    "follow": "Follow",
    "noDescriptionAvailable": "No description available.",
    "companySize": "Company Size",
    "noOpenPositions": "No open positions.",
    "errorLoadingJobs": "Error loading jobs"
}

keys_ar = {
    "companyProfile": "ملف الشركة",
    "follow": "متابعة",
    "noDescriptionAvailable": "لا يوجد وصف متاح.",
    "companySize": "حجم الشركة",
    "noOpenPositions": "لا توجد وظائف شاغرة.",
    "errorLoadingJobs": "خطأ في تحميل الوظائف"
}

add_keys(en_file, keys_en)
add_keys(ar_file, keys_ar)
