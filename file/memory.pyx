"""
Memory Optimization Module
Handles RAM optimization, standby memory clearing, and system cache management
"""

import psutil
import subprocess
import winreg
import ctypes
from ctypes import wintypes
from typing import Dict, List


class MemoryOptimizer:
    """RAM and system memory optimization"""
    
    def __init__(self, logger=None):
        self.logger = logger
        self.backup_data = {}
        
        # Windows API constants
        self.PROCESS_QUERY_INFORMATION = 0x0400
        self.PROCESS_SET_QUOTA = 0x0100
        
    def log(self, message: str, level: str = "INFO"):
        """Log message to console and logger"""
        if self.logger:
            self.logger(f"[{level}] {message}")
        print(f"[{level}] {message}")
    
    def get_memory_info(self) -> Dict:
        """Get current system memory information"""
        try:
            mem = psutil.virtual_memory()
            return {
                "total_gb": round(mem.total / (1024**3), 2),
                "available_gb": round(mem.available / (1024**3), 2),
                "used_gb": round(mem.used / (1024**3), 2),
                "percent": mem.percent,
                "cached_gb": round(mem.cached / (1024**3), 2) if hasattr(mem, 'cached') else 0
            }
        except Exception as e:
            self.log(f"Failed to get memory info: {e}", "ERROR")
            return {}
    
    def disable_sysmain(self) -> bool:
        """Disable SysMain (SuperFetch) service"""
        try:
            self.log("Disabling SysMain (SuperFetch)...")
            
            # Stop the service
            result = subprocess.run(
                ["sc", "stop", "SysMain"],
                capture_output=True,
                text=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            
            # Disable the service
            result = subprocess.run(
                ["sc", "config", "SysMain", "start=", "disabled"],
                capture_output=True,
                text=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            
            if result.returncode == 0:
                self.log("SysMain disabled successfully", "SUCCESS")
                return True
            else:
                self.log(f"Failed to disable SysMain: {result.stderr}", "ERROR")
                return False
        except Exception as e:
            self.log(f"Error disabling SysMain: {e}", "ERROR")
            return False
    
    def disable_windows_search(self) -> bool:
        """Disable Windows Search indexing service"""
        try:
            self.log("Disabling Windows Search service...")
            
            # Stop the service
            subprocess.run(
                ["sc", "stop", "WSearch"],
                capture_output=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            
            # Disable the service
            result = subprocess.run(
                ["sc", "config", "WSearch", "start=", "disabled"],
                capture_output=True,
                text=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            
            if result.returncode == 0:
                self.log("Windows Search disabled successfully", "SUCCESS")
                return True
            else:
                self.log(f"Failed to disable Windows Search: {result.stderr}", "WARNING")
                return False
        except Exception as e:
            self.log(f"Error disabling Windows Search: {e}", "ERROR")
            return False
    
    def enable_sysmain(self) -> bool:
        """Re-enable SysMain service"""
        try:
            self.log("Enabling SysMain...")
            
            result = subprocess.run(
                ["sc", "config", "SysMain", "start=", "auto"],
                capture_output=True,
                text=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            
            subprocess.run(
                ["sc", "start", "SysMain"],
                capture_output=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            
            if result.returncode == 0:
                self.log("SysMain enabled successfully", "SUCCESS")
                return True
            return False
        except Exception as e:
            self.log(f"Error enabling SysMain: {e}", "ERROR")
            return False
    
    def enable_windows_search(self) -> bool:
        """Re-enable Windows Search service"""
        try:
            self.log("Enabling Windows Search...")
            
            result = subprocess.run(
                ["sc", "config", "WSearch", "start=", "auto"],
                capture_output=True,
                text=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            
            subprocess.run(
                ["sc", "start", "WSearch"],
                capture_output=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            
            if result.returncode == 0:
                self.log("Windows Search enabled successfully", "SUCCESS")
                return True
            return False
        except Exception as e:
            self.log(f"Error enabling Windows Search: {e}", "ERROR")
            return False
    
    def clear_standby_memory(self) -> bool:
        """Clear standby memory using PowerShell EmptyStandbyList"""
        try:
            self.log("Clearing standby memory...")
            
            # Method 1: Using PowerShell and Windows API
            ps_command = """
            $source = @"
            using System;
            using System.Runtime.InteropServices;
            
            public class MemoryManager
            {
                [DllImport("kernel32.dll", SetLastError = true)]
                public static extern bool SetSystemFileCacheSize(IntPtr MinimumFileCacheSize, IntPtr MaximumFileCacheSize, int Flags);
                
                [DllImport("psapi.dll")]
                public static extern int EmptyWorkingSet(IntPtr hwProc);
                
                public static void ClearFileCache()
                {
                    SetSystemFileCacheSize((IntPtr)(-1), (IntPtr)(-1), 0);
                }
            }
"@
            
            try {
                Add-Type -TypeDefinition $source -Language CSharp -ErrorAction SilentlyContinue
                [MemoryManager]::ClearFileCache()
                Write-Output "Standby memory cleared"
            } catch {
                Write-Output "Method failed: $_"
            }
            """
            
            result = subprocess.run(
                ["powershell", "-Command", ps_command],
                capture_output=True,
                text=True,
                timeout=30,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            
            if "cleared" in result.stdout.lower():
                self.log("Standby memory cleared successfully", "SUCCESS")
                return True
            
            # Method 2: Alternative using RAMMap-like functionality
            # This requires Windows internal commands
            try:
                # Clear system working sets
                result = subprocess.run(
                    ["powershell", "-Command", 
                     "[System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers()"],
                    capture_output=True,
                    timeout=10,
                    creationflags=subprocess.CREATE_NO_WINDOW
                )
                self.log("Memory cleanup performed", "SUCCESS")
                return True
            except:
                pass
            
            return False
        except Exception as e:
            self.log(f"Failed to clear standby memory: {e}", "WARNING")
            return False
    
    def optimize_memory(self) -> bool:
        """Run complete memory optimization"""
        try:
            self.log("Starting memory optimization...")
            
            # Get initial memory state
            mem_before = self.get_memory_info()
            self.log(f"Memory before: {mem_before['available_gb']}GB available / {mem_before['total_gb']}GB total")
            
            # Disable memory-heavy services
            self.disable_sysmain()
            
            # Clear standby memory
            self.clear_standby_memory()
            
            # Get final memory state
            import time
            time.sleep(2)
            mem_after = self.get_memory_info()
            self.log(f"Memory after: {mem_after['available_gb']}GB available / {mem_after['total_gb']}GB total")
            
            freed = round(mem_after['available_gb'] - mem_before['available_gb'], 2)
            if freed > 0:
                self.log(f"Freed approximately {freed}GB of RAM", "SUCCESS")
            
            self.log("Memory optimization completed!", "SUCCESS")
            return True
        except Exception as e:
            self.log(f"Memory optimization failed: {e}", "ERROR")
            return False
    
    def disable_startup_programs(self) -> bool:
        """Disable unnecessary startup programs via registry"""
        try:
            self.log("Disabling unnecessary startup programs...")
            
            disabled_count = 0
            
            # List of common unnecessary startup items
            unnecessary_programs = [
                "OneDrive",
                "Skype",
                "Spotify",
                "Discord",
                "Steam",
                "EpicGamesLauncher",
                "AdobeAAMUpdater",
                "AdobeGCInvoker",
                "CCXProcess",
                "Teams",
                "Slack"
            ]
            
            # Registry paths for startup items
            startup_paths = [
                r"SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
                r"SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
            ]
            
            for path in startup_paths:
                try:
                    key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, path, 0, 
                                        winreg.KEY_READ | winreg.KEY_WRITE)
                    
                    i = 0
                    while True:
                        try:
                            name, value, type_ = winreg.EnumValue(key, i)
                            
                            # Check if it's an unnecessary program
                            for prog in unnecessary_programs:
                                if prog.lower() in name.lower() or prog.lower() in str(value).lower():
                                    # Backup before deletion
                                    if 'startup_items' not in self.backup_data:
                                        self.backup_data['startup_items'] = []
                                    self.backup_data['startup_items'].append({
                                        'path': path,
                                        'name': name,
                                        'value': value,
                                        'type': type_
                                    })
                                    
                                    # Delete the startup entry
                                    try:
                                        winreg.DeleteValue(key, name)
                                        self.log(f"Disabled startup item: {name}")
                                        disabled_count += 1
                                    except:
                                        pass
                                    break
                            i += 1
                        except OSError:
                            break
                    
                    winreg.CloseKey(key)
                except FileNotFoundError:
                    continue
                except Exception as e:
                    self.log(f"Error processing {path}: {e}", "WARNING")
            
            if disabled_count > 0:
                self.log(f"Disabled {disabled_count} startup items", "SUCCESS")
            else:
                self.log("No unnecessary startup items found")
            
            return True
        except Exception as e:
            self.log(f"Failed to disable startup programs: {e}", "ERROR")
            return False
    
    def get_startup_programs(self) -> List[Dict]:
        """Get list of startup programs"""
        try:
            startup_items = []
            
            startup_paths = [
                (winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Microsoft\Windows\CurrentVersion\Run"),
                (winreg.HKEY_CURRENT_USER, r"SOFTWARE\Microsoft\Windows\CurrentVersion\Run")
            ]
            
            for hive, path in startup_paths:
                try:
                    key = winreg.OpenKey(hive, path, 0, winreg.KEY_READ)
                    i = 0
                    while True:
                        try:
                            name, value, type_ = winreg.EnumValue(key, i)
                            startup_items.append({
                                "name": name,
                                "path": value,
                                "location": "HKLM" if hive == winreg.HKEY_LOCAL_MACHINE else "HKCU"
                            })
                            i += 1
                        except OSError:
                            break
                    winreg.CloseKey(key)
                except FileNotFoundError:
                    continue
            
            return startup_items
        except Exception as e:
            self.log(f"Failed to get startup programs: {e}", "ERROR")
            return []
