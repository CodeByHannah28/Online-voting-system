@echo off
REM Helper script to set SMTP environment variables on Windows (persistent via setx).
REM Usage: run as Administrator in cmd.exe: scripts\set_smtp_env.cmd your-email your-app-password

if "%~1"=="" (
  echo Usage: %~nx0 your-email your-gmail-app-password
  goto :eof
)

set EMAIL=%~1
set PASS=%~2

if "%PASS%"=="" (
  echo Password missing. Usage: %~nx0 your-email your-gmail-app-password
  goto :eof
)

echo Setting environment variables...
setx MAIL_SMTP_HOST "smtp.gmail.com"
setx MAIL_SMTP_PORT "587"
setx MAIL_SMTP_AUTH "true"
setx MAIL_SMTP_STARTTLS "true"
setx MAIL_SMTP_USER "%EMAIL%"
setx MAIL_SMTP_PASSWORD "%PASS%"
setx MAIL_FROM "Go Voter <%EMAIL%>"

echo Done. Restart Tomcat (or your servlet container) to pick up environment changes.

echo Reminder: do not commit credentials into source control.
