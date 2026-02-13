# Windows Gaming Optimizer Pro v1.0

A production-grade Windows system optimization tool specifically designed for competitive gaming. This application provides comprehensive system tweaks to minimize latency, stabilize frametimes, and reduce background overhead.

## ⚡ Features

### 🌐 Network Optimization
- **Advanced Adapter Configuration**
  - Disable Interrupt Moderation for lower latency
  - Disable Energy Efficient Ethernet
  - Disable Green Ethernet
  - Optimize Large Send Offload settings
  - Disable Receive Side Coalescing
  - Configure Flow Control
  - Enable RSS (Receive Side Scaling)

- **TCP/IP Stack Optimization**
  - Configure TCP autotuning
  - Disable ECN capability
  - Enable RSS globally
  - Optimize chimney offload settings

- **DNS Management**
  - Quick switch to Cloudflare DNS (1.1.1.1)
  - Quick switch to Google DNS (8.8.8.8)
  - DNS cache flushing
  - Winsock reset capability

- **Latency Testing**
  - Real-time ping tests to multiple servers
  - Before/after comparison metrics

### 💾 Memory Optimization
- Detect total system RAM
- Disable SysMain (Superfetch) service
- Optionally disable Windows Search indexing
- Clear standby memory using Windows API
- Manage startup programs
- View and optimize memory usage

### ⚙️ Services & Process Management
- **Background Process Monitor**
  - Real-time CPU and memory usage tracking
  - Kill high-resource processes
  - Protected process detection

- **Service Optimization**
  - Disable Xbox Game Bar and Game DVR
  - Temporarily disable Windows Update
  - Disable telemetry services
  - Service status monitoring

### 🖥️ System Performance Tweaks
- **Power Management**
  - Enable Ultimate Performance power plan
  - Optimize CPU scheduling

- **GPU Optimization**
  - Enable Hardware-Accelerated GPU Scheduling (Windows 10 2004+)
  - GPU information display

- **Visual Effects**
  - Disable Windows visual effects for best performance
  - Quick restore visual effects

- **Game-Specific Optimizations**
  - Disable Fullscreen Optimization for any game
  - Per-game compatibility settings

- **Advanced System Tweaks**
  - Optimize system responsiveness
  - Disable Nagle's Algorithm
  - Disable Windows tips and suggestions
  - Optimize Windows Game Mode

### 🔧 Advanced Features
- **Quick Optimization**
  - One-click apply all recommended settings
  
- **Backup & Restore**
  - Create system configuration backup
  - Restore default settings
  
- **Logging & Monitoring**
  - Real-time console output
  - Export logs to file
  - Detailed system information display

## 📋 System Requirements

- **Operating System:** Windows 10 (version 2004+) or Windows 11
- **Privileges:** Administrator rights required
- **Python:** Python 3.8 or higher
- **Dependencies:**
  - PyQt6 >= 6.4.0
  - psutil >= 5.9.0

## 🚀 Installation

### Step 1: Install Python
Download and install Python 3.8+ from [python.org](https://www.python.org/downloads/)

### Step 2: Install Dependencies
```bash
pip install -r requirements.txt
```

Or install manually:
```bash
pip install PyQt6 psutil
```

### Step 3: Run the Application
Right-click on `main.py` and select "Run as administrator" or:

```bash
# Run in PowerShell as Administrator
python main.py
```

## 📖 Usage Guide

### First Time Setup

1. **Launch as Administrator**
   - The application MUST be run with administrator privileges
   - If not running as admin, it will automatically request elevation

2. **Create a Backup**
   - Before making any changes, click "Create System Backup"
   - This allows you to restore settings if needed

3. **Network Optimization**
   - Click "Detect Network Adapter" in the Network tab
   - Select desired optimizations
   - Click "Optimize Network Adapter"
   - Optionally set DNS to Cloudflare or Google
   - Test latency to verify improvements

4. **Memory Optimization**
   - Review memory information
   - Select optimization options
   - Click "Optimize Memory"

5. **Services Optimization**
   - Review high CPU processes
   - Select services to disable
   - Click "Optimize Services"

6. **System Tweaks**
   - Set Ultimate Performance power plan
   - Enable GPU scheduling (requires restart)
   - Disable visual effects
   - For specific games: browse to .exe and disable fullscreen optimization

7. **Quick Optimization**
   - Go to Advanced tab
   - Click "OPTIMIZE EVERYTHING" for one-click setup
   - Review console output for details

### Important Notes

⚠️ **Restart Required**
Several optimizations require a system restart:
- Hardware GPU Scheduling
- Winsock Reset
- Visual Effects changes
- Some registry modifications

⚠️ **Windows Update**
If you disable Windows Update temporarily, remember to re-enable it for security updates!

⚠️ **Backup Important**
Always create a backup before making system changes. Use "Restore Defaults" to revert.

## 🎮 Recommended Settings for Gaming

### For Competitive FPS Games (CS2, Valorant, Apex)
- ✅ All network optimizations
- ✅ Set Cloudflare DNS
- ✅ Disable SysMain
- ✅ Clear standby memory
- ✅ Disable Xbox features
- ✅ Ultimate Performance power plan
- ✅ Disable visual effects
- ✅ Enable GPU scheduling
- ✅ Disable Nagle's Algorithm
- ✅ Optimize system responsiveness

### For MOBA Games (League, Dota 2)
- ✅ Network optimizations
- ✅ Set Google DNS
- ✅ Disable SysMain
- ✅ Ultimate Performance power plan
- ✅ Disable Xbox features
- ⚠️ Keep visual effects (optional)

### For MMO Games (WoW, FF14)
- ✅ Network optimizations
- ✅ Disable SysMain
- ✅ Clear standby memory
- ✅ Ultimate Performance power plan
- ⚠️ Don't disable Windows Search (for faster file access)

## 🛡️ Safety Features

1. **Admin Verification**
   - Automatic privilege check on startup
   - Prevents accidental system damage

2. **Protected Processes**
   - Critical system processes cannot be killed
   - Prevents system instability

3. **Confirmation Dialogs**
   - All major changes require user confirmation
   - Clear warnings about restart requirements

4. **Backup System**
   - Registry backup before modifications
   - One-click restore functionality

5. **Transparent Operations**
   - All operations logged in console
   - Export logs for troubleshooting

## 🔧 Technical Details

### Architecture

```
main.py              # Entry point with admin check
├── network.py       # Network optimization module
├── memory.py        # Memory optimization module
├── services.py      # Services & processes module
├── system_tweaks.py # System-level tweaks module
└── ui.py           # PyQt6 GUI interface
```

### Registry Modifications

The application modifies the following registry areas:
- Network adapter advanced properties
- TCP/IP stack configuration
- Power management settings
- Visual effects settings
- Game Mode configuration
- System responsiveness settings

### Services Modified

- SysMain (SuperFetch)
- Windows Search
- Windows Update (optional, temporary)
- DiagTrack (Telemetry)
- Xbox services

### PowerShell Usage

PowerShell commands are used for:
- Network adapter configuration
- Advanced system queries
- Service management

## 🐛 Troubleshooting

### Application won't start
- Ensure you're running as Administrator
- Check Python version (3.8+)
- Verify all dependencies are installed

### Network optimizations not applying
- Some adapters don't support all advanced properties
- Check console output for specific errors
- Try optimizing individual settings

### Changes not taking effect
- Restart your computer
- Some changes require logout/login
- Check if anti-virus is blocking modifications

### Performance worse after optimization
- Use "Restore Defaults" button
- Restart computer
- Some games may need specific settings (disable optimizations per-game)

## ⚖️ Anti-Cheat Compatibility

This tool does NOT:
- ❌ Inject into game processes
- ❌ Modify game files
- ❌ Use kernel drivers
- ❌ Hook system calls
- ❌ Interfere with anti-cheat systems

All modifications are standard Windows optimizations that work at the system level, not game level.

**Compatible with:**
- ✅ VAC (Valve Anti-Cheat)
- ✅ Vanguard (Valorant)
- ✅ Easy Anti-Cheat
- ✅ BattlEye
- ✅ FaceIt Client

## 📜 License

This software is provided "as-is" without warranty. Use at your own risk.

## 👨‍💻 Author

Created by a Senior Windows Systems Engineer with expertise in low-level performance optimization.

## 🙏 Credits

- Network optimization techniques from competitive gaming communities
- Memory management best practices from Windows internals documentation
- UI design using PyQt6 framework

## 📞 Support

For issues, questions, or suggestions:
1. Check the console output for error messages
2. Export logs using the "Export Log" button
3. Review the troubleshooting section above

---

**Version:** 1.0.0  
**Last Updated:** 2024  
**Platform:** Windows 10/11 (64-bit)

**⚡ Game On! ⚡**
