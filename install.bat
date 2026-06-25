@echo off
:: WHITE-HAT-STOAT Windows Installation Script
:: Version: 1.0.0

title WHITE-HAT-STOAT Installer

echo =============================================
echo 🦡 WHITE-HAT-STOAT - Windows Installation
echo =============================================
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  This installer requires administrator privileges.
    echo Please run as Administrator.
    pause
    exit /b 1
)

:: Set installation directory
set INSTALL_DIR=%PROGRAMFILES%\WHITE-HAT-STOAT
set DATA_DIR=%APPDATA%\WHITE-HAT-STOAT
set LOG_DIR=%PROGRAMDATA%\WHITE-HAT-STOAT\logs
set CONFIG_DIR=%PROGRAMDATA%\WHITE-HAT-STOAT\config

echo 📁 Installation Directory: %INSTALL_DIR%
echo 📁 Data Directory: %DATA_DIR%
echo 📁 Log Directory: %LOG_DIR%
echo.

:: Create directories
echo Creating directories...
mkdir "%INSTALL_DIR%" 2>nul
mkdir "%DATA_DIR%" 2>nul
mkdir "%LOG_DIR%" 2>nul
mkdir "%CONFIG_DIR%" 2>nul

:: Check Python installation
echo 🔍 Checking Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python not found. Please install Python 3.7 or higher.
    echo Download from https://python.org
    pause
    exit /b 1
)

:: Check Python version
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo ✅ Python %PYTHON_VERSION% found

:: Upgrade pip
echo 📦 Upgrading pip...
python -m pip install --upgrade pip setuptools wheel

:: Install requirements
echo 📦 Installing dependencies...
python -m pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo ⚠️  Some dependencies failed to install. Continue anyway?
    choice /C YN /M "Continue?"
    if errorlevel 2 exit /b 1
)

:: Install development dependencies (optional)
choice /C YN /M "Install development dependencies?"
if errorlevel 2 goto :skip_dev
python -m pip install -r requirements-dev.txt
:skip_dev

:: Install extra dependencies (optional)
choice /C YN /M "Install extra features (ML, Cloud, etc.)?"
if errorlevel 2 goto :skip_extra
python -m pip install -r requirements-extra.txt
:skip_extra

:: Copy application files
echo 📋 Copying application files...
xcopy /E /I /Y . "%INSTALL_DIR%"

:: Create shortcuts
echo 📌 Creating shortcuts...
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\WHITE-HAT-STOAT.lnk'); $Shortcut.TargetPath = 'python.exe'; $Shortcut.Arguments = '%INSTALL_DIR%\white_hat_stoat.py'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Save()"

:: Create start menu entry
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\WHITE-HAT-STOAT.lnk'); $Shortcut.TargetPath = 'python.exe'; $Shortcut.Arguments = '%INSTALL_DIR%\white_hat_stoat.py'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Save()"

:: Create environment variables
echo 📝 Setting environment variables...
setx STOAT_HOME "%INSTALL_DIR%"
setx STOAT_DATA "%DATA_DIR%"
setx STOAT_LOG "%LOG_DIR%"
setx STOAT_CONFIG "%CONFIG_DIR%"

:: Add to PATH
setx PATH "%PATH%;%INSTALL_DIR%"

:: Create sample configuration
echo 📝 Creating sample configuration...
if not exist "%CONFIG_DIR%\config.json" (
    copy "%INSTALL_DIR%\config\default.json" "%CONFIG_DIR%\config.json"
)

:: Setup firewall rules
echo 🔒 Configuring firewall...
netsh advfirewall firewall add rule name="WHITE-HAT-STOAT Web" dir=in action=allow protocol=TCP localport=5000
netsh advfirewall firewall add rule name="WHITE-HAT-STOAT Callback" dir=in action=allow protocol=TCP localport=5555
netsh advfirewall firewall add rule name="WHITE-HAT-STOAT Keylogger" dir=in action=allow protocol=TCP localport=4444
netsh advfirewall firewall add rule name="WHITE-HAT-STOAT Phishing" dir=in action=allow protocol=TCP localport=8080

:: Install as Windows Service (optional)
choice /C YN /M "Install as Windows Service?"
if errorlevel 2 goto :skip_service
echo Installing Windows Service...
python -m pip install pywin32
python "%INSTALL_DIR%\setup_service.py" install
:skip_service

echo.
echo =============================================
echo ✅ Installation Complete!
echo =============================================
echo.
echo 🦡 WHITE-HAT-STOAT has been installed.
echo.
echo 📁 Installation: %INSTALL_DIR%
echo 📁 Data: %DATA_DIR%
echo 📁 Logs: %LOG_DIR%
echo.
echo 📌 To run: python %INSTALL_DIR%\white_hat_stoat.py
echo 📌 Or use the shortcut on your Desktop
echo.
echo 💡 Type 'help' in the console for available commands
echo.
echo Press any key to exit...
pause >nul