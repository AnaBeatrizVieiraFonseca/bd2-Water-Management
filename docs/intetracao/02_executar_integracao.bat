@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

echo Integracao das medicoes MongoDB com os resumos e alertas MySQL.
echo Os dois bancos precisam estar em execucao neste computador.
echo.

if exist ".venv\Scripts\python.exe" goto bibliotecas

py -3 --version >nul 2>&1
if not errorlevel 1 (
    py -3 -m venv .venv
) else (
    python --version >nul 2>&1
    if errorlevel 1 goto sem_python
    python -m venv .venv
)
if errorlevel 1 goto erro

:bibliotecas
".venv\Scripts\python.exe" -c "import mysql.connector; import pymongo" >nul 2>&1
if not errorlevel 1 goto executar
echo Preparando as duas bibliotecas de conexao na primeira execucao...
".venv\Scripts\python.exe" -m pip install -r requirements.txt
if errorlevel 1 goto erro

:executar
echo Informe na janela a senha MySQL da conta rh_integracao_projeto.
echo A senha sera usada somente durante a execucao.
".venv\Scripts\python.exe" -u 01_integrar.py --janela-senha
if errorlevel 1 goto erro
echo.
echo Processamento concluido. Confira os resultados no MySQL.
pause
exit /b 0

:sem_python
echo Python nao foi encontrado neste computador.
echo Instale o Python com pip e suporte ao Tkinter para executar o integrador.
pause
exit /b 1

:erro
echo.
echo O processamento foi interrompido. Guarde a mensagem acima para conferir a causa.
pause
exit /b 1
