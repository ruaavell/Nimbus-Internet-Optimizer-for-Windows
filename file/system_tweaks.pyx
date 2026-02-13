"""
System Tweaks Module
Handles visual effects, GPU scheduling, and Windows performance optimizations
"""

import subprocess
import winreg
import ctypes
from typing import Dict, Optional


class SystemTweaks:
    """Windows system performance tweaks"""
    
    def __init__(self, logger=None):
        self.logger = logger
        self.backup_data = {}
    
    def log(self, message: str, level: str = "INFO"):
        """Log message to console and logger"""
        if self.logger:
            self.logger(f"[{level}] {message}")
        print(f"[{level}] {message}")
    
    def enable_hardware_gpu_scheduling(self) -> bool:
        """Enable Hardware-Accelerated GPU Scheduling (Windows 10 2004+)"""
        try:
            self.log("Enabling Hardware-Accelerated GPU Scheduling...")
            
            # Check Windows version first
            import sys
            if sys.getwindowsversion().build < 19041:
                self.log("Hardware GPU Scheduling requires Windows 10 version 2004 or later", "WARNING")
                return False
            
            # Enable via registry
            key_path = r"SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
            
            try:
                key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, key_path, 0, winreg.KEY_SET_VALUE)
                winreg.SetValueEx(key, "HwSchMode", 0, winreg.REG_DWORD, 2)
                winreg.CloseKey(key)
                
                self.log("Hardware-Accelerated GPU Scheduling enabled (restart required)", "SUCCESS")
                return True
            except FileNotFoundError:
                self.log("Graphics driver key not found - GPU may not support this feature", "WARNING")
                return False
        except Exception as e:
            self.log(f"Failed to enable GPU scheduling: {e}", "ERROR")
            return False
    
    def disable_visual_effects(self) -> bool:
        """Disable Windows visual effects for best performance"""
        try:
            self.log("Disabling visual effects...")
            
            # Set visual effects to "Best Performance"
            key_path = r"SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
            
            try:
                key = winreg.CreateKey(winreg.HKEY_CURRENT_USER, key_path)
                winreg.SetValueEx(key, "VisualFXSetting", 0, winreg.REG_DWORD, 2)  # 2 = Best Performance
                winreg.CloseKey(key)
            except Exception as e:
                self.log(f"Failed to set VisualFXSetting: {e}", "WARNING")
            
            # Disable specific visual effects
            dwm_key_path = r"SOFTWARE\Microsoft\Windows\DWM"
            
            try:
                key = winreg.CreateKey(winreg.HKEY_CURRENT_USER, dwm_key_path)
                
                # Disable window animations
                winreg.SetValueEx(key, "EnableAeroPeek", 0, winreg.REG_DWORD, 0)
                winreg.SetValueEx(key, "AlwaysHibernateThumbnails", 0, winreg.REG_DWORD, 0)
                
                winreg.CloseKey(key)
            except Exception as e:
                self.log(f"Failed to modify DWM settings: {e}", "WARNING")
            
            # Disable animations in SystemParametersInfo
            try:
                # Disable menu animations
                ctypes.windll.user32.SystemParametersInfoW(0x1013, 0, 0, 2)  # SPI_SETMENUANIMATION
                
                # Disable window animations
                ctypes.windll.user32.SystemParametersInfoW(0x1015, 0, 0, 2)  # SPI_SETCOMBOBOXANIMATION
                
                self.log("System animations disabled")
            except Exception as e:
                self.log(f"Failed to disable animations: {e}", "WARNING")
            
            # Additional performance tweaks in SystemParametersInfo
            userprefs_key = r"Control Panel\Desktop"
            
            try:
                key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, userprefs_key, 0, winreg.KEY_SET_VALUE)
                
                # Disable various animations and effects
                winreg.SetValueEx(key, "UserPreferencesMask", 0, winreg.REG_BINARY,
                                 b'\x90\x12\x01\x80\x10\x00\x00\x00')
                
                # Set menu show delay to 0
                winreg.SetValueEx(key, "MenuShowDelay", 0, winreg.REG_SZ, "0")
                
                winreg.CloseKey(key)
            except Exception as e:
                self.log(f"Failed to modify desktop preferences: {e}", "WARNING")
            
            self.log("Visual effects disabled (some changes require logout)", "SUCCESS")
            return True
        except Exception as e:
            self.log(f"Failed to disable visual effects: {e}", "ERROR")
            return False
    
    def enable_visual_effects(self) -> bool:
        """Re-enable Windows visual effects"""
        try:
            self.log("Enabling visual effects...")
            
            key_path = r"SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
            
            try:
                key = winreg.CreateKey(winreg.HKEY_CURRENT_USER, key_path)
                winreg.SetValueEx(key, "VisualFXSetting", 0, winreg.REG_DWORD, 0)  # 0 = Let Windows choose
                winreg.CloseKey(key)
            except:
                pass
            
            dwm_key_path = r"SOFTWARE\Microsoft\Windows\DWM"
            
            try:
                key = winreg.CreateKey(winreg.HKEY_CURRENT_USER, dwm_key_path)
                winreg.SetValueEx(key, "EnableAeroPeek", 0, winreg.REG_DWORD, 1)
                winreg.CloseKey(key)
            except:
                pass
            
            self.log("Visual effects enabled", "SUCCESS")
            return True
        except Exception as e:
            self.log(f"Failed to enable visual effects: {e}", "ERROR")
            return False
    
    def optimize_game_mode(self) -> bool:
        """Optimize Windows Game Mode settings"""
        try:
            self.log("Optimizing Game Mode...")
            
            # Enable Game Mode
            key_path = r"SOFTWARE\Microsoft\GameBar"
            
            try:
                key = winreg.CreateKey(winreg.HKEY_CURRENT_USER, key_path)
                winreg.SetValueEx(key, "AutoGameModeEnabled", 0, winreg.REG_DWORD, 1)
                winreg.CloseKey(key)
                self.log("Game Mode enabled")
            except Exception as e:
                self.log(f"Failed to enable Game Mode: {e}", "WARNING")
            
            # Optimize game scheduling
            key_path = r"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
            
            try:
                key = winreg.CreateKey(winreg.HKEY_LOCAL_MACHINE, key_path)
                
                # Set GPU priority to 8 (high)
                winreg.SetValueEx(key, "GPU Priority", 0, winreg.REG_DWORD, 8)
                
                # Set priority to High
                winreg.SetValueEx(key, "Priority", 0, winreg.REG_DWORD, 6)
                
                # Set Scheduling Category to High
                winreg.SetValueEx(key, "Scheduling Category", 0, winreg.REG_SZ, "High")
                
                # Set SFIO priority
                winreg.SetValueEx(key, "SFIO Priority", 0, winreg.REG_SZ, "High")
                
                winreg.CloseKey(key)
                self.log("Game scheduling optimized")
            except Exception as e:
                self.log(f"Failed to optimize game scheduling: {e}", "WARNING")
            
            self.log("Game Mode optimization completed", "SUCCESS")
            return True
        except Exception as e:
            self.log(f"Failed to optimize Game Mode: {e}", "ERROR")
            return False
    
    def disable_nagle_algorithm(self) -> bool:
        """Disable Nagle's Algorithm for reduced network latency"""
        try:
            self.log("Disabling Nagle's Algorithm...")
            
            # Find network interfaces
            key_path = r"SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
            
            try:
                key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, key_path, 0, winreg.KEY_READ)
                
                i = 0
                while True:
                    try:
                        subkey_name = winreg.EnumKey(key, i)
                        subkey_path = f"{key_path}\\{subkey_name}"
                        
                        try:
                            subkey = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, subkey_path, 0, 
                                                   winreg.KEY_SET_VALUE)
                            
                            # Disable Nagle's Algorithm
                            winreg.SetValueEx(subkey, "TcpAckFrequency", 0, winreg.REG_DWORD, 1)
                            winreg.SetValueEx(subkey, "TCPNoDelay", 0, winreg.REG_DWORD, 1)
                            
                            winreg.CloseKey(subkey)
                        except:
                            pass
                        
                        i += 1
                    except OSError:
                        break
                
                winreg.CloseKey(key)
                self.log("Nagle's Algorithm disabled", "SUCCESS")
                return True
            except Exception as e:
                self.log(f"Failed to access network interfaces: {e}", "WARNING")
                return False
        except Exception as e:
            self.log(f"Failed to disable Nagle's Algorithm: {e}", "ERROR")
            return False
    
    def optimize_system_responsiveness(self) -> bool:
        """Optimize system responsiveness for gaming"""
        try:
            self.log("Optimizing system responsiveness...")
            
            # Set system responsiveness
            key_path = r"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
            
            try:
                key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, key_path, 0, winreg.KEY_SET_VALUE)
                
                # Set SystemResponsiveness to 0 (games get more CPU time)
                winreg.SetValueEx(key, "SystemResponsiveness", 0, winreg.REG_DWORD, 0)
                
                # Disable throttling
                winreg.SetValueEx(key, "NetworkThrottlingIndex", 0, winreg.REG_DWORD, 0xFFFFFFFF)
                
                winreg.CloseKey(key)
                self.log("System responsiveness optimized")
            except Exception as e:
                self.log(f"Failed to set system responsiveness: {e}", "WARNING")
            
            # Optimize CPU scheduling
            key_path = r"SYSTEM\CurrentControlSet\Control\PriorityControl"
            
            try:
                key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, key_path, 0, winreg.KEY_SET_VALUE)
                
                # Win32PrioritySeparation: 0x26 = short, variable, foreground boost
                winreg.SetValueEx(key, "Win32PrioritySeparation", 0, winreg.REG_DWORD, 0x26)
                
                winreg.CloseKey(key)
                self.log("CPU scheduling optimized")
            except Exception as e:
                self.log(f"Failed to optimize CPU scheduling: {e}", "WARNING")
            
            self.log("System responsiveness optimization completed", "SUCCESS")
            return True
        except Exception as e:
            self.log(f"Failed to optimize system responsiveness: {e}", "ERROR")
            return False
    
    def disable_windows_tips(self) -> bool:
        """Disable Windows tips and suggestions"""
        try:
            self.log("Disabling Windows tips and suggestions...")
            
            settings = [
                (r"SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-338389Enabled", 0),
                (r"SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SystemPaneSuggestionsEnabled", 0),
                (r"SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SoftLandingEnabled", 0),
                (r"SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "ShowSyncProviderNotifications", 0),
            ]
            
            for key_path, value_name, value_data in settings:
                try:
                    key = winreg.CreateKey(winreg.HKEY_CURRENT_USER, key_path)
                    winreg.SetValueEx(key, value_name, 0, winreg.REG_DWORD, value_data)
                    winreg.CloseKey(key)
                except Exception as e:
                    self.log(f"Failed to set {value_name}: {e}", "WARNING")
            
            self.log("Windows tips disabled", "SUCCESS")
            return True
        except Exception as e:
            self.log(f"Failed to disable Windows tips: {e}", "ERROR")
            return False
    
    def get_gpu_info(self) -> Dict:
        """Get GPU information"""
        try:
            command = "Get-WmiObject Win32_VideoController | Select-Object Name, DriverVersion, VideoProcessor | ConvertTo-Json"
            result = subprocess.run(
                ["powershell", "-Command", command],
                capture_output=True,
                text=True,
                timeout=10,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            
            if result.returncode == 0:
                import json
                gpu_info = json.loads(result.stdout)
                if isinstance(gpu_info, dict):
                    return gpu_info
                elif isinstance(gpu_info, list) and len(gpu_info) > 0:
                    return gpu_info[0]
            
            return {}
        except Exception as e:
            self.log(f"Failed to get GPU info: {e}", "ERROR")
            return {}
