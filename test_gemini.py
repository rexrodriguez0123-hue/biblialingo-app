import google.generativeai as genai
import os
import sys

api_key = "AIzaSyALV1vYuJuk7xTdTRYYpFHIh2xkBBDT27g"
genai.configure(api_key=api_key)

try:
    model = genai.GenerativeModel('gemini-1.5-flash')
    response = model.generate_content("Hello, can you hear me?")
    print("SUCCESS: ", response.text)
except Exception as e:
    print("ERROR:")
    print(e)
