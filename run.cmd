@echo off
setlocal
if not exist venv\Scripts\activate.bat (
  echo Nevidim venv. Spust nejdriv first-run.cmd
  pause
  exit /b 1
)
call venv\Scripts\activate.bat
python spotify_mixer.py
pause
