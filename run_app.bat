@echo off
cd /d "%~dp0"
if exist .venv\Scripts\activate.bat call .venv\Scripts\activate.bat
echo Starting Hate Speech Detection App...
echo.
echo The app will open in your default browser.
echo If it doesn't open automatically, go to: http://localhost:8501
echo.
echo Press Ctrl+C to stop the server
echo.
streamlit run app.py --server.headless false





