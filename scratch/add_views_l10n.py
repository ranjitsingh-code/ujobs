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
    "viewsCount": "{count, plural, =0{No views} =1{1 view} other{{count} views}}",
    "@viewsCount": {}
}

keys_ar = {
    "viewsCount": "{count, plural, =0{لا توجد مشاهدات} =1{مشاهدة واحدة} other{{count} مشاهدات}}",
    "@viewsCount": {}
}

add_keys('lib/l10n/app_en.arb', keys_en)
add_keys('lib/l10n/app_ar.arb', keys_ar)
