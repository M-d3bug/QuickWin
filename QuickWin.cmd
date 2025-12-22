@echo off
setlocal enabledelayedexpansion
title QuickWin Clean Windows ToolKit
color 0F
cls

set "green=0A"
set "red=0C"
set "yellow=0E"
set "white=0F"

:: Check admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    color %red%
    echo.
    echo ========================================
    echo ADMINISTRATOR PRIVILEGES REQUIRED
    echo ========================================
    echo Please Run QuickWin as administrator.
    pause
    exit /b 1
)

:: Detect system winget
winget --version >nul 2>&1
if %errorlevel% equ 0 (
    set "has_winget=1"
) else (
    set "has_winget=0"
)

:menu
cls
color %white%
echo.
echo [1;32m=========================================================[0m
echo     QUICKWIN - CLEAN WINDOWS TOOLKIT
echo [1;32m=========================================================[0m
echo.
echo [1;33mSYSTEM SETUP:[0m
echo [[1;32m1[0m] Install WingetUI Package Manager
echo [[1;32m2[0m] Install Essential Apps (7-Zip, Brave, Notepad++, VLC, qView)
echo.
echo [1;33mWINDOWS OPTIMIZATION:[0m
echo [[1;32m3[0m] Apply Safe Tweaks
echo [[1;32m4[0m] Revert Tweaks
echo [[1;32m5[0m] Launch Chris Titus Utility
echo.
echo [1;33mCUSTOM COMMANDS:[0m
echo [[1;32m6[0m] [1;31mCommunity Utility Runner (Optional)[0m
echo.
echo [1;33mAUTOMATION:[0m
echo [[1;32m7[0m] Run Complete Setup (1+2+3+5)
echo.
echo [[1;32m0[0m] Exit
echo.
echo [1;32m=========================================================[0m
echo.
set /p choice=Enter choice (0-7): 
if "%choice%"=="1" goto install_wingetui
if "%choice%"=="2" goto install_apps
if "%choice%"=="3" goto apply_tweaks
if "%choice%"=="4" goto revert_tweaks
if "%choice%"=="5" goto launch_ctitus
if "%choice%"=="6" goto community_utility_runner
if "%choice%"=="7" goto run_all
if "%choice%"=="0" goto end
echo Invalid choice.
timeout /t 2 >nul
goto menu

:install_wingetui
cls
echo.
echo [1;32m=========================================================[0m
echo     INSTALLING WINGETUI PACKAGE MANAGER
echo [1;32m=========================================================[0m

if exist "%ProgramFiles%\UniGetUI\UniGetUI.exe" (
    echo [OK] UniGetUI already installed
    set "has_unigetui=1"
    pause
    goto menu
)

echo [..] Downloading and installing UniGetUI...
set "installer=%TEMP%\UniGetUI.Installer.exe"
set "download_url=https://github.com/marticliment/UniGetUI/releases/latest/download/UniGetUI.Installer.exe"

powershell -NoProfile -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri '%download_url%' -OutFile '%installer%' -UseBasicParsing"
if not exist "%installer%" (
    echo [FAILED] Download failed
    pause
    goto menu
)

start /wait "" "%installer%" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART 
:: Safety kill to ensure no background splash screen or UI remains
taskkill /f /im "UniGetUI.exe" /t >nul 2>&1
del /f /q "%installer%" 2>nul
echo [OK] UniGetUI installed
set "has_unigetui=1"
pause
goto menu

:install_apps
cls
echo.
echo [1;32m=========================================================[0m
echo     INSTALLING ESSENTIAL APPS
echo [1;32m=========================================================[0m

if exist "%ProgramFiles%\UniGetUI\UniGetUI.exe" set "has_unigetui=1"

if %has_winget%==1 (
    echo [INFO] Using system winget
    set "winget_cmd=winget"
) else if defined has_unigetui if exist "%ProgramFiles%\UniGetUI\winget-cli_x64\winget.exe" (
    echo [INFO] Using UniGetUI bundled winget
    set "winget_cmd=%ProgramFiles%\UniGetUI\winget-cli_x64\winget.exe"
) else (
    echo [ERROR] No winget available. Install WingetUI first.
    pause
    goto menu
)

echo [..] Installing via winget...

"%winget_cmd%" install -e --id 7zip.7zip --source winget --silent --disable-interactivity -h
"%winget_cmd%" install -e --id Notepad++.Notepad++ --source winget --silent --disable-interactivity -h
"%winget_cmd%" install -e --id VideoLAN.VLC --source winget --silent --disable-interactivity -h
"%winget_cmd%" install -e --id jurplel.qView --source winget --silent --disable-interactivity -h
"%winget_cmd%" install -e --id Brave.Brave --source winget --silent --disable-interactivity -h

call :restore_photo_viewer
echo [OK] Essential apps installed via winget
pause
goto menu

:install_apps_no_pause
if exist "%ProgramFiles%\UniGetUI\UniGetUI.exe" set "has_unigetui=1"

if %has_winget%==1 (
    set "winget_cmd=winget"
) else if defined has_unigetui if exist "%ProgramFiles%\UniGetUI\winget-cli_x64\winget.exe" (
    set "winget_cmd=%ProgramFiles%\UniGetUI\winget-cli_x64\winget.exe"
) else (
    exit /b 1
)

"%winget_cmd%" install -e --id 7zip.7zip --source winget --silent --disable-interactivity -h
"%winget_cmd%" install -e --id Notepad++.Notepad++ --source winget --silent --disable-interactivity -h
"%winget_cmd%" install -e --id VideoLAN.VLC --source winget --silent --disable-interactivity -h
"%winget_cmd%" install -e --id jurplel.qView --source winget --silent --disable-interactivity -h
"%winget_cmd%" install -e --id Brave.Brave --source winget --silent --disable-interactivity -h

call :restore_photo_viewer
exit /b 0

:install_wingetui_no_pause
if exist "%ProgramFiles%\UniGetUI\UniGetUI.exe" exit /b 0
set "installer=%TEMP%\UniGetUI.Installer.exe"
set "download_url=https://github.com/marticliment/UniGetUI/releases/latest/download/UniGetUI.Installer.exe"
powershell -NoProfile -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri '%download_url%' -OutFile '%installer%' -UseBasicParsing"
if not exist "%installer%" exit /b 1
start /wait "" "%installer%" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
:: Safety kill to ensure no background splash screen or UI remains
taskkill /f /im "UniGetUI.exe" /t >nul 2>&1
del /f /q "%installer%" 2>nul
set "has_unigetui=1"
exit /b 0

:apply_tweaks_silent
:: --- Explorer & Interface Tweaks ---
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v LaunchTo /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSyncProviderNotifications /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" /v TaskbarEndTask /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v Flags /t REG_SZ /d 506 /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f >nul 2>&1

:: --- Start Menu & Taskbar ---
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_IrisRecommendations /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarMn /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_TrackProgs /t REG_DWORD /d 0 /f >nul 2>&1

:: --- Search & Feeds ---
reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v DisableSearchBoxSuggestions /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v EnableFeeds /t REG_DWORD /d 0 /f >nul 2>&1

:: --- Privacy & Telemetry ---
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338393Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353694Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353696Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338387Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353698Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v DisabledByGroupPolicy /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v LetAppsGetDiagnosticInfo /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Personalization\Settings" /v AcceptedPrivacyPolicy /t REG_DWORD /d 0 /f >nul 2>&1

:: --- Cloud Content ---
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableSoftLanding /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsSpotlightFeatures /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Policies\Microsoft\Windows\CloudContent" /v DisableTailoredExperiencesWithDiagnosticData /t REG_DWORD /d 1 /f >nul 2>&1

:: --- System & Diagnostics ---
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableActivityFeed /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Policies\Microsoft\Windows\HandwritingErrorReports" /v PreventHandwritingErrorReports /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\HandwritingErrorReports" /v PreventHandwritingErrorReports /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Policies\Microsoft\Windows\TabletPC" /v PreventHandwritingDataSharing /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v PreventHandwritingDataSharing /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v VerboseStatus /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Control\CrashControl" /v DisplayParameters /t REG_DWORD /d 1 /f >nul 2>&1

:: --- Service Cleanup ---
sc config Fax start=disabled >nul 2>&1
sc config RetailDemo start=disabled >nul 2>&1
sc config RemoteRegistry start=disabled >nul 2>&1
sc config WerSvc start=disabled >nul 2>&1
sc config XblAuthManager start=disabled >nul 2>&1
sc config XblGameSave start=disabled >nul 2>&1
sc config XboxNetApiSvc start=disabled >nul 2>&1
sc config XboxGipSvc start=disabled >nul 2>&1

:: --- Appx Bloat Removal ---
echo [--] Removing third-party apps...
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"king.com.CandyCrushSaga\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"king.com.CandyCrushSodaSaga\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"ShazamEntertainmentLtd.Shazam\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"Flipboard.Flipboard\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"9E2F88E3.Twitter\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"ClearChannelRadioDigital.iHeartRadio\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"D5EA27B7.Duolingo-LearnLanguagesforFree\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"AdobeSystemsIncorporated.AdobePhotoshopExpress\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"PandoraMediaInc.29680B314EFC2\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"46928bounde.EclipseManager\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"ActiproSoftwareLLC.562882FEEB491\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"SpotifyAB.SpotifyMusic\" | Remove-AppxPackage" 2>nul

echo QuickWin_Cleanup_Applied > "%TEMP%\QuickWin_Cleanup.marker"
exit /b 0

:: --- Restore Old Windows PhotoViewer ---
:restore_photo_viewer
reg add "HKCR\Applications\photoviewer.dll\shell\open\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
reg add "HKCR\Applications\photoviewer.dll\shell\open\DropTarget" /v Clsid /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f >nul 2>&1
for %%i in (.jpg .jpeg .png .bmp .gif .tif .tiff .ico .webp) do (
    reg add "HKCR\%%i\OpenWithList\photoviewer.dll" /f >nul 2>&1
    reg add "HKCR\%%i\OpenWithProgids" /v "PhotoViewer.FileAssoc.Tiff" /t REG_SZ /d "" /f >nul 2>&1
)

exit /b 0

:apply_tweaks
cls
echo.
echo [1;32m=========================================================[0m
echo APPLYING WINDOWS CLEANUP and TWEAKS
echo [1;32m=========================================================[0m
echo Safe optimizations:
echo - Explorer improvements
echo - Start/Taskbar cleanup
echo - Privacy
echo - Background management
echo - Service cleanup
echo - Usability tweaks
echo - Appx Bloat Removal
echo.
set /p confirm=Apply? (Y/N):
if /i not "%confirm%"=="Y" goto menu

echo [..] Applying tweaks...

:: --- Explorer & Interface Tweaks ---
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v LaunchTo /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSyncProviderNotifications /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" /v TaskbarEndTask /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v Flags /t REG_SZ /d 506 /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f >nul 2>&1

:: --- Start Menu & Taskbar ---
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_IrisRecommendations /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarMn /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_TrackProgs /t REG_DWORD /d 0 /f >nul 2>&1

:: --- Search & Feeds ---
reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v DisableSearchBoxSuggestions /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v EnableFeeds /t REG_DWORD /d 0 /f >nul 2>&1

:: --- Privacy & Telemetry ---
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338393Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353694Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353696Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338387Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353698Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v DisabledByGroupPolicy /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v LetAppsGetDiagnosticInfo /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Personalization\Settings" /v AcceptedPrivacyPolicy /t REG_DWORD /d 0 /f >nul 2>&1

:: --- Cloud Content ---
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableSoftLanding /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsSpotlightFeatures /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Policies\Microsoft\Windows\CloudContent" /v DisableTailoredExperiencesWithDiagnosticData /t REG_DWORD /d 1 /f >nul 2>&1

:: --- System & Diagnostics ---
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableActivityFeed /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Policies\Microsoft\Windows\HandwritingErrorReports" /v PreventHandwritingErrorReports /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\HandwritingErrorReports" /v PreventHandwritingErrorReports /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Policies\Microsoft\Windows\TabletPC" /v PreventHandwritingDataSharing /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v PreventHandwritingDataSharing /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v VerboseStatus /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Control\CrashControl" /v DisplayParameters /t REG_DWORD /d 1 /f >nul 2>&1

:: --- Service Cleanup ---
sc config Fax start=disabled >nul 2>&1
sc config RetailDemo start=disabled >nul 2>&1
sc config RemoteRegistry start=disabled >nul 2>&1
sc config WerSvc start=disabled >nul 2>&1
sc config XblAuthManager start=disabled >nul 2>&1
sc config XblGameSave start=disabled >nul 2>&1
sc config XboxNetApiSvc start=disabled >nul 2>&1
sc config XboxGipSvc start=disabled >nul 2>&1

:: --- Appx Bloat Removal ---
echo [--] Removing third-party apps...
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"king.com.CandyCrushSaga\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"king.com.CandyCrushSodaSaga\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"ShazamEntertainmentLtd.Shazam\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"Flipboard.Flipboard\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"9E2F88E3.Twitter\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"ClearChannelRadioDigital.iHeartRadio\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"D5EA27B7.Duolingo-LearnLanguagesforFree\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"AdobeSystemsIncorporated.AdobePhotoshopExpress\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"PandoraMediaInc.29680B314EFC2\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"46928bounde.EclipseManager\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"ActiproSoftwareLLC.562882FEEB491\" | Remove-AppxPackage" 2>nul
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage \"SpotifyAB.SpotifyMusic\" | Remove-AppxPackage" 2>nul

echo QuickWin_Cleanup_Applied > "%TEMP%\QuickWin_Cleanup.marker"
echo [OK] Tweaks applied successfully

set /p restart=Restart Explorer? (Y/N):
if /i "%restart%"=="Y" (
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
)
pause
goto menu

:revert_tweaks
cls
echo.
echo [1;32m=========================================================[0m
echo REVERTING TWEAKS
echo [1;32m=========================================================[0m
if not exist "%TEMP%\QuickWin_Cleanup.marker" (
echo [INFO] No tweaks detected
pause
goto menu
)
set /p confirm=Revert? (Y/N):
if /i not "%confirm%"=="Y" goto menu

echo [..] Reverting tweaks...

:: --- Explorer & Interface Tweaks ---
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v LaunchTo /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSyncProviderNotifications /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" /v TaskbarEndTask /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v Flags /t REG_SZ /d 510 /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 1 /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 6 /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 10 /f >nul 2>&1

:: --- Start Menu & Taskbar ---
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_IrisRecommendations /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarMn /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_TrackProgs /t REG_DWORD /d 1 /f >nul 2>&1

:: --- Search & Feeds ---
reg delete "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v DisableSearchBoxSuggestions /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v EnableFeeds /f >nul 2>&1

:: --- Privacy & Telemetry ---
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338393Enabled /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353694Enabled /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353696Enabled /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338387Enabled /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353698Enabled /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v DisabledByGroupPolicy /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v LetAppsGetDiagnosticInfo /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Personalization\Settings" /v AcceptedPrivacyPolicy /f >nul 2>&1

:: --- Cloud Content ---
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableSoftLanding /f >nul 2>&1
reg delete "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsSpotlightFeatures /f >nul 2>&1
reg delete "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /f >nul 2>&1
reg delete "HKCU\Software\Policies\Microsoft\Windows\CloudContent" /v DisableTailoredExperiencesWithDiagnosticData /f >nul 2>&1

:: --- System & Diagnostics ---
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableActivityFeed /f >nul 2>&1
reg delete "HKCU\Software\Policies\Microsoft\Windows\HandwritingErrorReports" /v PreventHandwritingErrorReports /f >nul 2>&1
reg delete "HKLM\Software\Policies\Microsoft\Windows\HandwritingErrorReports" /v PreventHandwritingErrorReports /f >nul 2>&1
reg delete "HKCU\Software\Policies\Microsoft\Windows\TabletPC" /v PreventHandwritingDataSharing /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v PreventHandwritingDataSharing /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v VerboseStatus /f >nul 2>&1
reg delete "HKLM\System\CurrentControlSet\Control\CrashControl" /v DisplayParameters /f >nul 2>&1

:: --- Service Cleanup ---
sc config Fax start=demand >nul 2>&1
sc config RetailDemo start=demand >nul 2>&1
sc config RemoteRegistry start=disabled >nul 2>&1
sc config WerSvc start=demand >nul 2>&1
sc config XblAuthManager start=demand >nul 2>&1
sc config XblGameSave start=demand >nul 2>&1
sc config XboxNetApiSvc start=demand >nul 2>&1
sc config XboxGipSvc start=demand >nul 2>&1

:: --- Appx Bloat Removal ---
echo [--] Note: Third-party apps must be reinstalled manually from the Microsoft Store.

del /f /q "%TEMP%\QuickWin_Cleanup.marker" 2>nul
echo [OK] Tweaks reverted

set /p restart=Restart Explorer? (Y/N):
if /i "%restart%"=="Y" (
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
)
pause
goto menu

:launch_ctitus
cls
echo.
echo [1;32m=========================================================[0m
echo LAUNCHING CHRIS TITUS UTILITY
echo [1;32m=========================================================[0m
echo [..] Starting utility...
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm 'https://christitus.com/win' | iex"
echo [OK] Utility finished
pause
goto menu

:community_utility_runner
setlocal EnableDelayedExpansion
cls
color 0B
echo.
echo [1;36m=========================================================[0m
echo           SYSTEM UTILITY and MAINTENANCE RUNNER
echo [1;36m=========================================================[0m
echo.
echo  This tool executes external community-maintained scripts 
echo  for system optimization and license management.
echo.
echo  [1;33mCOMMON USE CASES:[0m
echo  - [1;32mSystem Genuine Verification, Digital Licensing[0m
echo  - [1;32mWindows Telemetry and Bloatware Removal[0m
echo  - [1;32mAdvanced Post-Install Configurations[0m
echo.
echo  [1;35mINSTRUCTIONS:[0m
echo  1. Paste your command(s) below. 
echo  2. Press [1;32mENTER TWO TIMES[0m to execute. 
echo.
echo  Support pasting multiple lines (like Registry tweaks) 
echo.
echo ---------------------------------------------------------

:: Reset the buffer
set "full_payload="

:input_loop
set "line_input="
set /p "line_input=[1;36m > [0m"

:: Check if the user is finished
if /i "!line_input!"=="" goto :process_payload
if "!line_input!"=="" goto :process_payload

:: Append the line to the payload with a semicolon separator for PowerShell
if defined full_payload (
    set "full_payload=!full_payload!; !line_input!"
) else (
    set "full_payload=!line_input!"
)
goto :input_loop

:process_payload
if "!full_payload!"=="" endlocal & goto menu

cls
echo [1;31m[!] SECURITY CHECK[0m
echo.
echo You are about to execute the following command(s):
echo ---------------------------------------------------------
echo [1;33m!full_payload![0m
echo ---------------------------------------------------------
echo.
set /p "confirm=Type 'Y' to confirm execution: "

if /i "!confirm!" neq "Y" (
    echo [!] Cancelled.
    timeout /t 2 >nul
    endlocal & goto menu
)

echo.
echo [1;32m[PROCESS][0m Running commands via PowerShell...
echo.

:: We pass the multi-line payload as a single environment variable
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$in = $env:full_payload; if($in -match '^http' -and $in -notmatch ' '){iex(irm $in)}else{iex $in}"

echo.
echo [1;36m=========================================================[0m
echo [OK] All tasks completed.
echo [1;36m=========================================================[0m
pause
endlocal
goto menu

:run_all
cls
echo.
echo [1;32m=========================================================[0m
echo COMPLETE SETUP AUTOMATION
echo [1;32m=========================================================[0m
echo This will:
echo 1. Install WingetUI
echo 2. Install Essential Apps
echo 3. Apply Safe Tweaks
echo 4. Launch Chris Titus Utility
echo.
set /p confirm=Continue? (Y/N): 
if /i not "%confirm%"=="Y" goto menu

echo.
echo [1/4] WingetUI
call :install_wingetui_no_pause
echo [OK] WingetUI done

echo.
echo [2/4] Essential Apps Pack
call :install_apps_no_pause
echo [OK] Essential Apps Pack done

echo.
echo [3/4] Applying Safe Tweaks
call :apply_tweaks_silent
echo [OK] Tweaks applied

echo.
echo [4/4] Chris Titus Utility
echo [..] Launching...
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm 'https://christitus.com/win' | iex"
echo [OK] Utility finished

echo.
echo [1;32m=========================================================[0m
echo Complete setup finished!
echo [1;32m=========================================================[0m
pause
goto menu

:end
cls
echo.
echo [1;32m=========================================================[0m
echo Thank you for using QuickWin
echo [1;32m=========================================================[0m
timeout /t 1 >nul
exit /b 0
exit /b 0