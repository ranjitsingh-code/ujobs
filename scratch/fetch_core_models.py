import requests
import json

base = "https://ujobapi.gidentex.com/api/v1"
s_auth = {"email": "mdazadhossain95@gmail.com", "password": "Azad6103051@"}
e_auth = {"email": "nexoviasolutions@gmail.com", "password": "Azad613051@"}

s_res = requests.post(f"{base}/auth/login", json=s_auth).json()
e_res = requests.post(f"{base}/auth/login", json=e_auth).json()

print("SEEKER AUTH:")
print(json.dumps(s_res, indent=2))
print("\nEMPLOYER AUTH:")
print(json.dumps(e_res, indent=2))

jobs = requests.get(f"{base}/public/jobs?limit=1").json()
print("\nJOBS:")
print(json.dumps(jobs, indent=2))

companies = requests.get(f"{base}/public/companies?limit=1").json()
print("\nCOMPANIES:")
print(json.dumps(companies, indent=2))
