@echo off
setlocal
where py >nul 2>nul || (
  echo Python launcher 'py' nenalezen. Nainstaluj Python 3.10+ a spust znovu.
  pause
  exit /b 1
)
py -3 -m venv venv || goto :err
call venv\Scripts\activate.bat
python -m pip install --upgrade pip
pip install -r requirements.txt || goto :err
if not exist sources.yaml copy sources.example.yaml sources.yaml >nul
echo Oteviram sources.yaml - vypln OAuth a playlisty...
start notepad.exe sources.yaml
echo Az doplnis sources.yaml, zavri Notepad a stiskni libovolnou klavesu zde...
pause >nul
python spotify_mixer.py || goto :err
echo Hotovo!
pause
exit /b 0
:err
echo.
echo Nastala chyba. Mrkni vyse na hlasky.
pause
