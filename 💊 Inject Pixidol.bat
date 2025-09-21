@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

if not exist "reduced" mkdir "reduced"

for %%F in (*.mp4) do (
    echo Checking: %%F
    ffprobe -v quiet -show_entries format_tags=comment -of csv=p=0 "%%F" > "temp_%%~nF.txt" 2>nul

    findstr /I /C:"Processed" "temp_%%~nF.txt" >nul 2>&1
    set "found_marker=!errorlevel!"
    if exist "temp_%%~nF.txt" del "temp_%%~nF.txt" >nul 2>&1

    if !found_marker! equ 0 (
        echo   ^> SKIPPED: File already has Processed marker
    ) else (
        echo   ^> PROCESSING: Converting...
        ffmpeg -v info -i "%%F" -map_metadata 0 -metadata comment="Processed ▣" -c:v libx264 -crf 23 -preset fast -c:a aac -b:a 128k -y "reduced\%%~nF.mp4"
        if !errorlevel! equ 0 (
            echo   ^> SUCCESS: Converted
        ) else (
            echo   ^> ERROR: Failed to convert
        )
    )
    echo.
)

echo Conversion completed!
pause
