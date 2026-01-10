import urllib.request
import json
import sys

api_key = "AIzaSyALV1vYuJuk7xTdTRYYpFHIh2xkBBDT27g"
url = f"https://generativelanguage.googleapis.com/v1beta/models?key={api_key}"
req = urllib.request.Request(url)

try:
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode('utf-8'))
        for model in data.get('models', []):
            print(model['name'])
except urllib.error.HTTPError as e:
    print(f"HTTP Error: {e.code}")
    print(e.read().decode('utf-8'))
except Exception as e:
    print(e)
