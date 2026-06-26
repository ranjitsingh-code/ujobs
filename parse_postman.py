import json

with open("jobportal-mobile-api.postman_collection (1).json", "r") as f:
    data = json.load(f)

endpoints = []
def parse_items(items):
    for item in items:
        if "item" in item:
            parse_items(item["item"])
        else:
            req = item.get("request", {})
            method = req.get("method", "GET")
            url = req.get("url", {})
            if isinstance(url, dict):
                path = url.get("path", [])
                raw_url = "/" + "/".join(path)
            else:
                raw_url = str(url)
            
            body = req.get("body", {}).get("raw", "")
            endpoints.append({
                "name": item.get("name"),
                "method": method,
                "url": raw_url,
                "body": body
            })

parse_items(data.get("item", []))
for e in endpoints:
    print(f"{e['method']} {e['url']} - {e['name']}")
print(f"\nTotal endpoints: {len(endpoints)}")
