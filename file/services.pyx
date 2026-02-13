"""
Services and Process Optimization Module
Handles Windows services, background processes, and gaming-specific tweaks
"""

import psutil
import subprocess
import winreg
import os
from typing import List, Dict, Tuple


class ServiceOptimizer:
    """Windows services and process optimization"""
    
    def __init__(self, logger=None):
        self.logger = logger
        self.backup_data = {}
        
        # System processes that should never be killed
        self.protected_processes = {
            "system", "registry", "smss.exe", "csrss.exe", "wininit.exe",
            "services.exe", "lsass.exe", "svchost.exe", "winlogon.exe",
            "explorer.exe", "dwm.exe", "taskmgr.exe", "python.exe",
            "pythonw.exe", "conhost.exe", "fontdrvhost.exe"
        }
    
    def log(self, message: str, level: str = "INFO"):
        """Log message to console and logger"""
        if self.logger:
            self.logger(f"[{level}] {message}")
        print(f"[{level}] {message}")
    
    def get_high_cpu_processes(self, threshold: float = 5.0, limit: int = 20) -> List[Dict]:
        """Get processes using more than threshold% CPU"""
        try:
            processes = []
            for proc in psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_percent', 'username']):
                try:
                    info = proc.info
                    # Get CPU usage (needs interval)
                    cpu = proc.cpu_percent(interval=0.1)
                    
                    if cpu > threshold and info['name'].lower() not in self.protected_processes:
                        processes.append({
                            'pid': info['pid'],
                            'name': info['name'],
                            'cpu_percent': round(cpu, 2),
                            'memory_percent': round(info['memory_percent'], 2),
                            'username': info['username']
                        })
                except (psutil.NoSuchProcess, psutil.AccessDenied):
                    continue
            
            # Sort by CPU usage
            processes.sort(key=lambda x: x['cpu_percent'], reverse=True)
            return processes[:limit]
        except Exception as e:
            self.log(f"Failed to get processes: {e}", "ERROR")
            return []
    
    def kill_process(self, pid: int, name: str) -> bool:
        """Kill a process by PID"""
        try:
            if name.lower() in self.protected_processes:
                self.log(f"Cannot kill protected process: {name}", "WARNING")
                return False
            
            proc = psutil.Process(pid)
            proc.terminate()
            proc.wait(timeout=5)
            
            self.log(f"Terminated process: {name} (PID: {pid})", "SUCCESS")
            return True
        except psutil.NoSuchProcess:
            self.log(f"Process {name} already terminated", "INFO")
            return True
        except psutil.AccessDenied:
            self.log(f"Access denied: Cannot kill {name}", "ERROR")
            return False
        except Exception as e:
            self.log(f"Failed to kill process {name}: {e}", "ERROR")
            return False
    
    def disable_windows_update(self) -> bool:
        """Temporarily disable Windows Update service"""
        try:
            self.log("Disabling Windows Update service...")
            
            services = ["wuauserv", "WaaSMedicSvc", "UsoSvc"]
            
            for service in services:
                try:
                    # Stop the service
                    subprocess.run(
                        ["sc", "stop", service],
                        capture_output=True,
                        creationflags=subprocess.CREATE_NO_WINDOW
                    )
                    
                    # Disable the service
                    subprocess.run(
                        ["sc", "config", service, "start=", "disabled"],
                        capture_output=True,
                        creationflags=subprocess.CREATE_NO_WINDOW
                    )
                    
                    self.log(f"Disabled service: {service}")
                except Exception as e:
                    self.log(f"Could not disable {service}: {e}", "WARNING")
            
            self.log("Windows Update services disabled", "SUCCESS")
            return True
        except Exception as e:
            self.log(f"Failed to disable Windows Update: {e}", "ERROR")
            return False
    
    def enable_windows_update(self) -> bool:
        """Re-enable Windows Update service"""
        try:
            self.log("Enabling Windows Update service...")
            
            services = ["wuauserv", "WaaSMedicSvc", "UsoSvc"]
            
            for service in services:
                try:
                    subprocess.run(
                        ["sc", "config", service, "start=", "auto"],
                        capture_output=True,
                        creationflags=subprocess.CREATE_NO_WINDOW
                    )
                    
                    subprocess.run(
                        ["sc", "start", service],
                        capture_output=True,
                        creationflags=subprocess.CREATE_NO_WINDOW
                    )
                    
                    self.log(f"Enabled service: {service}")
                except Exception as e:
                    self.log(f"Could not enable {service}: {e}", "WARNING")
            
            self.log("Windows Update services enabled", "SUCCESS")
            return True
        except Exception as e:
            self.log(f"Failed to enable Windows Update: {e}", "ERROR")
            return False
    
    def disable_xbox_features(self) -> bool:
        """Disable Xbox Game Bar and Game DVR"""
        try:
            self.log("Disabling Xbox gaming features...")
            
            # Disable Xbox Game Bar
            try:
                key_path = r"SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"
                key = winreg.CreateKey(winreg.HKEY_CURRENT_USER, key_path)
                winreg.SetValueEx(key, "AppCaptureEnabled", 0, winreg.REG_DWORD, 0)
                winreg.SetValueEx(key, "GameDVR_Enabled", 0, winreg.REG_DWORD, 0)
                winreg.CloseKey(key)
                self.log("Xbox Game DVR disabled")
            except Exception as e:
                self.log(f"Failed to disable Game DVR: {e}", "WARNING")
            
            # Disable Game Bar
            try:
                key_path = r"SOFTWARE\Microsoft\GameBar"
                key = winreg.CreateKey(winreg.HKEY_CURRENT_USER, key_path)
                winreg.SetValueEx(key, "AutoGameModeEnabled", 0, winreg.REG_DWORD, 0)
                winreg.SetValueEx(key, "AllowAutoGameMode", 0, winreg.REG_DWORD, 0)
                winreg.SetValueEx(key, "UseNexusForGameBarEnabled", 0, winreg.REG_DWORD, 0)
                winreg.CloseKey(key)
                self.log("Xbox Game Bar disabled")
            except Exception as e:
                self.log(f"Failed to disable Game Bar: {e}", "WARNING")
            
            # Disable Game Mode notifications
            try:
                key_path = r"SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"
                key = winreg.CreateKey(winreg.HKEY_LOCAL_MACHINE, key_path)
                winreg.SetValueEx(key, "GameDVR_Enabled", 0, winreg.REG_DWORD, 0)
                winreg.CloseKey(key)
            except Exception as e:
                self.log(f"Failed to disable Game Mode notifications: {e}", "WARNING")
            
            self.log("Xbox features disabled successfully", "SUCCESS")
            return True
        except Exception as e:
            self.log(f"Failed to disable Xbox features: {e}", "ERROR")
            return False
    
    def enable_xbox_features(self) -> bool:
        """Re-enable Xbox Game Bar and Game DVR"""
        try:
            self.log("Enabling Xbox gaming features...")
            
            # Enable Xbox Game Bar
            try:
                key_path = r"SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"
                key = winreg.CreateKey(winreg.HKEY_CURRENT_USER, key_path)
                winreg.SetValueEx(key, "AppCaptureEnabled", 0, winreg.REG_DWORD, 1)
                winreg.SetValueEx(key, "GameDVR_Enabled", 0, winreg.REG_DWORD, 1)
                winreg.CloseKey(key)
            except:
                pass
            
            # Enable Game Bar
            try:
                key_path = r"SOFTWARE\Microsoft\GameBar"
                key = winreg.CreateKey(winreg.HKEY_CURRENT_USER, key_path)
                winreg.SetValueEx(key, "AutoGameModeEnabled", 0, winreg.REG_DWORD, 1)
                winreg.SetValueEx(key, "AllowAutoGameMode", 0, winreg.REG_DWORD, 1)
                winreg.CloseKey(key)
            except:
                pass
            
            self.log("Xbox features enabled", "SUCCESS")
            return True
        except Exception as e:
            self.log(f"Failed to enable Xbox features: {e}", "ERROR")
            return False
    
    def set_ultimate_performance_plan(self) -> bool:
        """Enable Ultimate Performance power plan"""
        try:
            self.log("Setting Ultimate Performance power plan...")
            
            # First, check if Ultimate Performance plan exists
            result = subprocess.run(
                ["powercfg", "/list"],
                capture_output=True,
                text=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            
            ultimate_guid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
            
            # If it doesn't exist, duplicate the High Performance plan
            if ultimate_guid not in result.stdout:
                subprocess.run(
                    ["powercfg", "-duplicatescheme", ultimate_guid],
                    capture_output=True,
                    creationflags=subprocess.CREATE_NO_WINDOW
                )
                self.log("Created Ultimate Performance power plan")
            
            # Set Ultimate Performance as active
            result = subprocess.run(
                ["powercfg", "/setactive", ultimate_guid],
                capture_output=True,
                text=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            
            if result.returncode == 0:
                self.log("Ultimate Performance power plan activated", "SUCCESS")
                return True
            
            # Fallback to High Performance
            high_perf_guid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
            subprocess.run(
                ["powercfg", "/setactive", high_perf_guid],
                capture_output=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            self.log("High Performance power plan activated (fallback)", "SUCCESS")
            return True
        except Exception as e:
            self.log(f"Failed to set power plan: {e}", "ERROR")
            return False
    
    def disable_fullscreen_optimization(self, exe_path: str) -> bool:
        """Disable fullscreen optimizations for a specific game executable"""
        try:
            if not os.path.exists(exe_path):
                self.log(f"Game executable not found: {exe_path}", "ERROR")
                return False
            
            self.log(f"Disabling fullscreen optimization for: {os.path.basename(exe_path)}")
            
            # Add registry entry to disable fullscreen optimization
            key_path = r"SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
            
            try:
                key = winreg.CreateKey(winreg.HKEY_CURRENT_USER, key_path)
                
                # Set compatibility flags
                # DISABLEDXMAXIMIZEDWINDOWEDMODE = Disable fullscreen optimizations
                # HIGHDPIAWARE = High DPI aware
                value = "~ DISABLEDXMAXIMIZEDWINDOWEDMODE HIGHDPIAWARE"
                
                winreg.SetValueEx(key, exe_path, 0, winreg.REG_SZ, value)
                winreg.CloseKey(key)
                
                self.log(f"Fullscreen optimization disabled for {os.path.basename(exe_path)}", "SUCCESS")
                return True
            except Exception as e:
                self.log(f"Failed to modify registry: {e}", "ERROR")
                return False
        except Exception as e:
            self.log(f"Failed to disable fullscreen optimization: {e}", "ERROR")
            return False
    
    def disable_telemetry_services(self) -> bool:
        """Disable Windows telemetry and data collection services"""
        try:
            self.log("Disabling telemetry services...")
            
            telemetry_services = [
                "DiagTrack",  # Connected User Experiences and Telemetry
                "dmwappushservice",  # Device Management Wireless Application Protocol
                "PcaSvc",  # Program Compatibility Assistant
                "RemoteRegistry"  # Remote Registry
            ]
            
            for service in telemetry_services:
                try:
                    subprocess.run(
                        ["sc", "stop", service],
                        capture_output=True,
                        creationflags=subprocess.CREATE_NO_WINDOW
                    )
                    
                    subprocess.run(
                        ["sc", "config", service, "start=", "disabled"],
                        capture_output=True,
                        creationflags=subprocess.CREATE_NO_WINDOW
                    )
                    
                    self.log(f"Disabled telemetry service: {service}")
                except Exception as e:
                    self.log(f"Could not disable {service}: {e}", "WARNING")
            
            self.log("Telemetry services disabled", "SUCCESS")
            return True
        except Exception as e:
            self.log(f"Failed to disable telemetry: {e}", "ERROR")
            return False
    
    def get_service_status(self, service_name: str) -> str:
        """Get the status of a Windows service"""
        try:
            result = subprocess.run(
                ["sc", "query", service_name],
                capture_output=True,
                text=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            
            if "RUNNING" in result.stdout:
                return "Running"
            elif "STOPPED" in result.stdout:
                return "Stopped"
            else:
                return "Unknown"
        except:
            return "Unknown"
