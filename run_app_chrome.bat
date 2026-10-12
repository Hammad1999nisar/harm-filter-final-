@echo off
cd /d "%~dp0"
if exist .venv\Scripts\activate.bat call .venv\Scripts\activate.bat
echo Starting Hate Speech Detection App in Google Chrome...
echo.
start chrome.exe http://localhost:8501
timeout /t 3 /nobreak >nul
streamlit run app.py --server.headless false





