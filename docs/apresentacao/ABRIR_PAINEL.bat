@echo off
setlocal
set "APP_DIR=%~dp0"
set "VENV_DIR=%APP_DIR%.venv"
set "PYTHON_APP=%VENV_DIR%\Scripts\python.exe"

if exist "%PYTHON_APP%" goto check_packages

py -3 -m venv "%VENV_DIR%"
if errorlevel 1 goto error

:check_packages
"%PYTHON_APP%" -c "import streamlit, pandas, mysql.connector, pymongo" >nul 2>&1
if not errorlevel 1 goto run_app

echo Installing panel dependencies. Internet may be required on first run.
"%PYTHON_APP%" -m pip install -r "%APP_DIR%requirements.txt"
if errorlevel 1 goto error

:run_app
"%PYTHON_APP%" -m streamlit run "%APP_DIR%app.py" --server.address 127.0.0.1 --server.port 8501 --server.headless true --browser.gatherUsageStats false --theme.base light --theme.primaryColor "#168aad"
if errorlevel 1 pause
exit /b 0

:error
echo Could not prepare or start the panel. Check that Python 3 is installed.
pause
exit /b 1
