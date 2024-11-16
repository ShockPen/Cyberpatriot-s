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



