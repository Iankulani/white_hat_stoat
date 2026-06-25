# WHITE-HAT-STOAT Windows Installation Script (PowerShell)
# Version: 1.0.0

param(
    [switch]$Dev,
    [switch]$Extra,
    [switch]$Service,
    [switch]$SkipDeps
)

$ErrorActionPreference = "Stop"

# Colors
$RED = [System.ConsoleColor]::Red
$GREEN = [System.ConsoleColor]::Green
$YELLOW = [System.ConsoleColor]::Yellow
$BLUE = [System.ConsoleColor]::Blue
$CYAN = [System.ConsoleColor]::Cyan
$PURPLE = [System.ConsoleColor]::Magenta
$WHITE = [System.ConsoleColor]::White

function Write-Color {
    param([string]$Message, [System.ConsoleColor]$Color = $WHITE)
    Write-Host $Message -ForegroundColor $Color
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check admin privileges
if (-not (Test-Administrator)) {
    Write-Color "⚠️  This installer requires administrator privileges." $YELLOW
    Write-Color "Please run as Administrator." $YELLOW
    Read-Host "Press Enter to exit"
    exit 1
}

# Clear screen
Clear-Host

Write-Color "=============================================" $PURPLE
Write-Color "🦡 WHITE-HAT-STOAT - Windows Installation" $WHITE
Write-Color "=============================================" $PURPLE
Write-Host ""

# Installation directories
$INSTALL_DIR = "$env:ProgramFiles\WHITE-HAT-STOAT"
$DATA_DIR = "$env:APPDATA\WHITE-HAT-STOAT"
$LOG_DIR = "$env:ProgramData\WHITE-HAT-STOAT\logs"
$CONFIG_DIR = "$env:ProgramData\WHITE-HAT-STOAT\config"
$BIN_DIR = "$env:ProgramFiles\WHITE-HAT-STOAT\bin"

Write-Color "📁 Installation Directory: $INSTALL_DIR" $CYAN
Write-Color "📁 Data Directory: $DATA_DIR" $CYAN
Write-Color "📁 Log Directory: $LOG_DIR" $CYAN
Write-Color "📁 Config Directory: $CONFIG_DIR" $CYAN
Write-Host ""

# Create directories
Write-Color "Creating directories..." $BLUE
New-Item -ItemType Directory -Force -Path $INSTALL_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $DATA_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $LOG_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $CONFIG_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $BIN_DIR | Out-Null

# Check Python
Write-Color "🔍 Checking Python..." $BLUE
try {
    $pythonVersion = python --version 2>&1
    Write-Color "✅ $pythonVersion found" $GREEN
} catch {
    Write-Color "❌ Python not found." $RED
    Write-Color "Please install Python 3.7 or higher from https://python.org" $YELLOW
    Read-Host "Press Enter to exit"
    exit 1
}

# Upgrade pip
Write-Color "📦 Upgrading pip..." $BLUE
python -m pip install --upgrade pip setuptools wheel

# Install dependencies
if (-not $SkipDeps) {
    Write-Color "📦 Installing dependencies..." $BLUE
    python -m pip install -r requirements.txt
    
    if ($LASTEXITCODE -ne 0) {
        Write-Color "⚠️  Some dependencies failed to install." $YELLOW
        $response = Read-Host "Continue anyway? (y/n)"
        if ($response -ne 'y') {
            exit 1
        }
    }
}

# Install dev dependencies
if ($Dev) {
    Write-Color "📦 Installing development dependencies..." $BLUE
    python -m pip install -r requirements-dev.txt
}

# Install extra dependencies
if ($Extra) {
    Write-Color "📦 Installing extra dependencies..." $BLUE
    python -m pip install -r requirements-extra.txt
}

# Copy application files
Write-Color "📋 Copying application files..." $BLUE
Copy-Item -Path ".\*" -Destination $INSTALL_DIR -Recurse -Force -Exclude @('.git', '.venv', '__pycache__', '*.pyc')

# Create batch file for easy execution
Write-Color "📌 Creating executable..." $BLUE
$batchContent = @"
@echo off
cd /d "$INSTALL_DIR"
python white_hat_stoat.py %*
"@
$batchContent | Out-File -FilePath "$BIN_DIR\white-hat-stoat.bat" -Encoding ASCII

# Add to PATH
Write-Color "📝 Adding to PATH..." $BLUE
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($currentPath -notlike "*$BIN_DIR*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$BIN_DIR", "Machine")
}

# Set environment variables
Write-Color "📝 Setting environment variables..." $BLUE
[Environment]::SetEnvironmentVariable("STOAT_HOME", $INSTALL_DIR, "Machine")
[Environment]::SetEnvironmentVariable("STOAT_DATA", $DATA_DIR, "Machine")
[Environment]::SetEnvironmentVariable("STOAT_LOG", $LOG_DIR, "Machine")
[Environment]::SetEnvironmentVariable("STOAT_CONFIG", $CONFIG_DIR, "Machine")

# Create sample configuration
Write-Color "📝 Creating sample configuration..." $BLUE
$configPath = "$CONFIG_DIR\config.json"
if (-not (Test-Path $configPath)) {
    if (Test-Path "$INSTALL_DIR\config\default.json") {
        Copy-Item "$INSTALL_DIR\config\default.json" $configPath
    }
}

# Configure firewall
Write-Color "🔒 Configuring firewall..." $BLUE
$ports = @(5000, 5555, 4444, 8080)
foreach ($port in $ports) {
    $ruleName = "WHITE-HAT-STOAT Port $port"
    netsh advfirewall firewall add rule name="$ruleName" dir=in action=allow protocol=TCP localport=$port | Out-Null
}
Write-Color "✅ Firewall rules added" $GREEN

# Install as Windows Service
if ($Service) {
    Write-Color "📦 Installing Windows Service..." $BLUE
    python -m pip install pywin32
    python "$INSTALL_DIR\setup_service.py" install
    python "$INSTALL_DIR\setup_service.py" start
}

# Create Desktop shortcut
Write-Color "📌 Creating desktop shortcut..." $BLUE
$WScriptShell = New-Object -ComObject WScript.Shell
$shortcut = $WScriptShell.CreateShortcut("$env:USERPROFILE\Desktop\WHITE-HAT-STOAT.lnk")
$shortcut.TargetPath = "python.exe"
$shortcut.Arguments = "$INSTALL_DIR\white_hat_stoat.py"
$shortcut.WorkingDirectory = $INSTALL_DIR
$shortcut.Save()

# Create Start Menu shortcut
$startMenuDir = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
$shortcut = $WScriptShell.CreateShortcut("$startMenuDir\WHITE-HAT-STOAT.lnk")
$shortcut.TargetPath = "python.exe"
$shortcut.Arguments = "$INSTALL_DIR\white_hat_stoat.py"
$shortcut.WorkingDirectory = $INSTALL_DIR
$shortcut.Save()

Write-Host ""
Write-Color "=============================================" $PURPLE
Write-Color "✅ Installation Complete!" $GREEN
Write-Color "=============================================" $PURPLE
Write-Host ""
Write-Color "🦡 WHITE-HAT-STOAT has been installed." $WHITE
Write-Host ""
Write-Color "📁 Installation: $INSTALL_DIR" $CYAN
Write-Color "📁 Data: $DATA_DIR" $CYAN
Write-Color "📁 Logs: $LOG_DIR" $CYAN
Write-Color "📁 Config: $CONFIG_DIR" $CYAN
Write-Host ""
Write-Color "📌 To run:" $WHITE
Write-Color "   python $INSTALL_DIR\white_hat_stoat.py" $CYAN
Write-Color "   white-hat-stoat.bat" $CYAN
Write-Host ""
Write-Color "💡 Type 'help' in the console for available commands" $WHITE
Write-Host ""
Write-Color "⚠️  Note: Some features require additional configuration." $YELLOW
Write-Color "   Edit $CONFIG_DIR\config.json to customize." $YELLOW
Write-Host ""
Read-Host "Press Enter to exit"