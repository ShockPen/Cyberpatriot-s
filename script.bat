@echo off
:: Set the drive to search for media files
set drive=C:\

:: List of file extensions to delete
set extensions=*.mp3 *.mp4 *.avi *.mkv *.jpg *.jpeg *.png *.gif *.bmp *.wav *.flac *.mov *.wmv *.mp3 *.ogg

:: Confirm with the user before deletion
echo WARNING: This script will delete all media files with the following extensions:
echo %extensions%
echo Are you sure you want to continue? (Y/N)
set /p confirm=Choose Y or N: 

if /i "%confirm%" neq "Y" goto end

:: Start the deletion process
for %%f in (%extensions%) do (
    echo Deleting all %%f files on %drive%...
    del /f /s /q %drive%\%%f
)

echo Media files have been deleted.
:end

@echo off
:: Check if Google Update service is running, if not, start it
echo Checking for Google Chrome updates...

:: Launch Google Update (gupdate) to trigger the update check
start "" "C:\Program Files (x86)\Google\Update\GoogleUpdate.exe" /ua /installsource=default

:: Wait for the update process to finish
timeout /t 10

:: Launch Chrome after updating
echo Launching Google Chrome...
start chrome

:end
echo Chrome update process completed.

@echo off
:: Turn on Windows Firewall for all profiles (Domain, Private, and Public)

echo Enabling Windows Firewall...

:: Enable firewall for all profiles
netsh advfirewall set allprofiles state on

:: Check the status of the firewall to confirm it's enabled
netsh advfirewall show allprofiles
:end
echo Firewall has been enabled.

@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Define download URLs
set "NOTEPAD_PLUS_PLUS_URL=https://github.com/notepad-plus-plus/notepad-plus-plus/releases/latest/download/npp.x64.Installer.exe"
set "SEVEN_ZIP_URL=https://www.7-zip.org/a/7z1900-x64.exe"
set "WIRESHARK_URL=https://www.wireshark.org/download.html"

:: Define paths for downloaded installers
set "TEMP_DIR=%TEMP%\installers"
set "NOTEPAD_PLUS_PLUS_INSTALLER=%TEMP_DIR%\npp_installer.exe"
set "SEVEN_ZIP_INSTALLER=%TEMP_DIR%\7zip_installer.exe"
set "WIRESHARK_INSTALLER=%TEMP_DIR%\wireshark_installer.exe"

:: Create a temporary directory for storing installers
mkdir "%TEMP_DIR%"

:: Download Notepad++ Installer
echo Downloading Notepad++...
bitsadmin /transfer notepadpp_download /download /priority high %NOTEPAD_PLUS_PLUS_URL% %NOTEPAD_PLUS_PLUS_INSTALLER%

:: Download 7-Zip Installer
echo Downloading 7-Zip...
bitsadmin /transfer sevenzip_download /download /priority high %SEVEN_ZIP_URL% %SEVEN_ZIP_INSTALLER%

:: Download Wireshark Installer (You can replace with actual URL)
echo Downloading Wireshark...
bitsadmin /transfer wireshark_download /download /priority high %WIRESHARK_URL% %WIRESHARK_INSTALLER%

:: Install Notepad++ Silently
echo Installing Notepad++...
start /wait %NOTEPAD_PLUS_PLUS_INSTALLER% /S

:: Install 7-Zip Silently
echo Installing 7-Zip...
start /wait %SEVEN_ZIP_INSTALLER% /S

:: Install Wireshark Silently
echo Installing Wireshark...
start /wait %WIRESHARK_INSTALLER% /S

:: Clean up the installer files
echo Cleaning up...
del /f /q "%NOTEPAD_PLUS_PLUS_INSTALLER%"
del /f /q "%SEVEN_ZIP_INSTALLER%"
del /f /q "%WIRESHARK_INSTALLER%"

:: Remove temporary directory
rmdir /s /q "%TEMP_DIR%"

echo Update completed successfully!

@echo off
echo Uninstalling CCleaner...

:: Check if CCleaner is installed and get the path to the uninstaller
set uninstall_path=""

:: Default path where CCleaner is usually installed
set uninstall_path_x86="C:\Program Files (x86)\CCleaner\uninstall.exe"
set uninstall_path_x64="C:\Program Files\CCleaner\uninstall.exe"

:: Check for the presence of the uninstaller in common locations
if exist %uninstall_path_x86% (
    set uninstall_path=%uninstall_path_x86%
) else if exist %uninstall_path_x64% (
    set uninstall_path=%uninstall_path_x64%
) else (
    echo CCleaner not found on this system.
    pause
    exit /b
)

:: Run the uninstaller
echo Found CCleaner at %uninstall_path%. Uninstalling...
"%uninstall_path%" /silent

:: Check if uninstallation was successful
if %ERRORLEVEL% == 0 (
    echo CCleaner has been successfully uninstalled.
) else (
    echo There was an error uninstalling CCleaner.
)

pause



