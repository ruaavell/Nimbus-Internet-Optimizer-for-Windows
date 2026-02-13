"""
Network Optimization Module
Handles network adapter configuration, TCP/IP stack optimization, and DNS management
"""

import subprocess
import winreg
import re
import time
from typing import Dict, List, Tuple, Optional


class NetworkOptimizer:
    """Network optimization for low-latency gaming"""
    
    def __init__(self, logger=None):
        self.logger = logger
        self.backup_data = {}
        
    def log(self, message: str, level: str = "INFO"):
        """Log message to console and logger"""
        if self.logger:
            self.logger(f"[{level}] {message}")
        print(f"[{level}] {message}")
    
    def run_powershell(self, command: str) -> Tuple[bool, str]:
        """Execute PowerShell command and return result"""
        try:
            result = subprocess.run(
                ["powershell", "-Command", command],
                capture_output=True,
                text=True,
                timeout=30,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            return result.returncode == 0, result.stdout + result.stderr
        except Exception as e:
            return False, str(e)
    
    def get_active_adapter(self) -> Optional[str]:
        """Detect the active network adapter"""
        try:
            command = "Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Select-Object -First 1 -ExpandProperty Name"
            success, output = self.run_powershell(command)
            if success and output.strip():
                adapter_name = output.strip()
                self.log(f"Active adapter detected: {adapter_name}")
                return adapter_name
            return None
        except Exception as e:
            self.log(f"Failed to detect adapter: {e}", "ERROR")
            return None
    
    def backup_adapter_settings(self, adapter_name: str):
        """Backup current adapter advanced properties"""
        try:
            command = f"Get-NetAdapterAdvancedProperty -Name '{adapter_name}' | Select-Object RegistryKeyword, DisplayValue | ConvertTo-Json"
            success, output = self.run_powershell(command)
            if success:
                self.backup_data['adapter_settings'] = output
                self.log("Adapter settings backed up successfully")
        except Exception as e:
            self.log(f"Failed to backup adapter settings: {e}", "ERROR")
    
    def set_adapter_property(self, adapter_name: str, property_name: str, value: str) -> bool:
        """Set network adapter advanced property"""
        try:
            command = f"Set-NetAdapterAdvancedProperty -Name '{adapter_name}' -RegistryKeyword '{property_name}' -RegistryValue '{value}'"
            success, output = self.run_powershell(command)
            if success:
                self.log(f"Set {property_name} = {value}")
                return True
            else:
                self.log(f"Failed to set {property_name}: {output}", "WARNING")
                return False
        except Exception as e:
            self.log(f"Error setting {property_name}: {e}", "ERROR")
            return False
    
    def optimize_adapter(self, adapter_name: str) -> bool:
        """Apply optimal adapter settings for gaming"""
        try:
            self.log("Starting network adapter optimization...")
            self.backup_adapter_settings(adapter_name)
            
            # Disable Interrupt Moderation (reduces latency)
            self.set_adapter_property(adapter_name, "*InterruptModeration", "0")
            
            # Disable Energy Efficient Ethernet
            self.set_adapter_property(adapter_name, "EEE", "0")
            self.set_adapter_property(adapter_name, "*EEE", "0")
            
            # Disable Green Ethernet
            self.set_adapter_property(adapter_name, "GreenEthernet", "0")
            self.set_adapter_property(adapter_name, "*GreenEthernet", "0")
            
            # Disable Large Send Offload for lower latency
            self.set_adapter_property(adapter_name, "*LsoV2IPv4", "0")
            self.set_adapter_property(adapter_name, "*LsoV2IPv6", "0")
            
            # Disable Receive Side Coalescing
            self.set_adapter_property(adapter_name, "*RSC", "0")
            self.set_adapter_property(adapter_name, "RSCEnabled", "0")
            
            # Disable Flow Control
            self.set_adapter_property(adapter_name, "*FlowControl", "0")
            
            # Set Receive/Transmit Buffers to optimal values
            self.set_adapter_property(adapter_name, "*ReceiveBuffers", "512")
            self.set_adapter_property(adapter_name, "*TransmitBuffers", "512")
            
            # Enable RSS (Receive Side Scaling) for better multi-core performance
            self.set_adapter_property(adapter_name, "*RSS", "1")
            
            self.log("Network adapter optimization completed!", "SUCCESS")
            return True
        except Exception as e:
            self.log(f"Adapter optimization failed: {e}", "ERROR")
            return False
    
    def set_speed_duplex(self, adapter_name: str, speed: str = "1.0 Gbps Full Duplex") -> bool:
        """Set network adapter speed and duplex mode"""
        try:
            # Common speed values: "10 Mbps Full Duplex", "100 Mbps Full Duplex", "1.0 Gbps Full Duplex"
            command = f"Set-NetAdapterAdvancedProperty -Name '{adapter_name}' -RegistryKeyword '*SpeedDuplex' -DisplayValue '{speed}'"
            success, output = self.run_powershell(command)
            if success:
                self.log(f"Speed/Duplex set to: {speed}")
                return True
            return False
        except Exception as e:
            self.log(f"Failed to set speed/duplex: {e}", "ERROR")
            return False
    
    def optimize_tcp_stack(self) -> bool:
        """Optimize TCP/IP stack for gaming"""
        try:
            self.log("Optimizing TCP/IP stack...")
            
            # Set TCP autotuning to normal (better for gaming than disabled)
            subprocess.run(
                ["netsh", "interface", "tcp", "set", "global", "autotuninglevel=normal"],
                capture_output=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            self.log("TCP autotuning set to normal")
            
            # Disable ECN capability (can cause issues with some routers)
            subprocess.run(
                ["netsh", "interface", "tcp", "set", "global", "ecncapability=disabled"],
                capture_output=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            self.log("ECN capability disabled")
            
            # Enable RSS (Receive Side Scaling)
            subprocess.run(
                ["netsh", "interface", "tcp", "set", "global", "rss=enabled"],
                capture_output=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            self.log("RSS enabled")
            
            # Set chimney offload to disabled (better compatibility)
            subprocess.run(
                ["netsh", "interface", "tcp", "set", "global", "chimney=disabled"],
                capture_output=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            self.log("Chimney offload disabled")
            
            # Disable Direct Cache Access
            subprocess.run(
                ["netsh", "interface", "tcp", "set", "global", "dca=disabled"],
                capture_output=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            self.log("DCA disabled")
            
            # Set network throttling index to disabled (reduces artificial latency)
            try:
                key_path = r"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
                key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, key_path, 0, winreg.KEY_SET_VALUE)
                winreg.SetValueEx(key, "NetworkThrottlingIndex", 0, winreg.REG_DWORD, 0xFFFFFFFF)
                winreg.CloseKey(key)
                self.log("Network throttling disabled")
            except Exception as e:
                self.log(f"Failed to disable network throttling: {e}", "WARNING")
            
            self.log("TCP/IP stack optimization completed!", "SUCCESS")
            return True
        except Exception as e:
            self.log(f"TCP stack optimization failed: {e}", "ERROR")
            return False
    
    def set_dns(self, provider: str, adapter_name: Optional[str] = None) -> bool:
        """Set DNS servers (Cloudflare or Google)"""
        try:
            if not adapter_name:
                adapter_name = self.get_active_adapter()
            
            if not adapter_name:
                self.log("No active adapter found", "ERROR")
                return False
            
            dns_servers = {
                "cloudflare": ("1.1.1.1", "1.0.0.1"),
                "google": ("8.8.8.8", "8.8.4.4")
            }
            
            if provider.lower() not in dns_servers:
                self.log(f"Unknown DNS provider: {provider}", "ERROR")
                return False
            
            primary, secondary = dns_servers[provider.lower()]
            
            self.log(f"Setting DNS to {provider.title()}...")
            
            # Set primary DNS
            command1 = f"Set-DnsClientServerAddress -InterfaceAlias '{adapter_name}' -ServerAddresses '{primary}','{secondary}'"
            success, output = self.run_powershell(command1)
            
            if success:
                self.log(f"DNS set to {provider.title()}: {primary}, {secondary}", "SUCCESS")
                return True
            else:
                self.log(f"Failed to set DNS: {output}", "ERROR")
                return False
        except Exception as e:
            self.log(f"DNS configuration failed: {e}", "ERROR")
            return False
    
    def flush_dns(self) -> bool:
        """Flush DNS cache"""
        try:
            result = subprocess.run(
                ["ipconfig", "/flushdns"],
                capture_output=True,
                text=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            if result.returncode == 0:
                self.log("DNS cache flushed successfully", "SUCCESS")
                return True
            return False
        except Exception as e:
            self.log(f"Failed to flush DNS: {e}", "ERROR")
            return False
    
    def reset_winsock(self) -> bool:
        """Reset Winsock catalog (requires restart)"""
        try:
            self.log("Resetting Winsock catalog...")
            
            subprocess.run(
                ["netsh", "winsock", "reset"],
                capture_output=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            
            subprocess.run(
                ["netsh", "int", "ip", "reset"],
                capture_output=True,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            
            self.log("Winsock reset completed (restart required)", "SUCCESS")
            return True
        except Exception as e:
            self.log(f"Winsock reset failed: {e}", "ERROR")
            return False
    
    def test_latency(self, target: str = "1.1.1.1", count: int = 4) -> Dict[str, float]:
        """Test network latency using ping"""
        try:
            self.log(f"Testing latency to {target}...")
            
            result = subprocess.run(
                ["ping", "-n", str(count), target],
                capture_output=True,
                text=True,
                timeout=10,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            
            output = result.stdout
            
            # Parse ping results
            avg_match = re.search(r"Average = (\d+)ms", output)
            min_match = re.search(r"Minimum = (\d+)ms", output)
            max_match = re.search(r"Maximum = (\d+)ms", output)
            
            if avg_match:
                results = {
                    "target": target,
                    "average": float(avg_match.group(1)),
                    "minimum": float(min_match.group(1)) if min_match else 0,
                    "maximum": float(max_match.group(1)) if max_match else 0
                }
                self.log(f"Latency to {target}: Avg={results['average']}ms, Min={results['minimum']}ms, Max={results['maximum']}ms")
                return results
            else:
                self.log(f"Could not parse ping results for {target}", "WARNING")
                return {"target": target, "average": 0, "minimum": 0, "maximum": 0}
        except Exception as e:
            self.log(f"Latency test failed: {e}", "ERROR")
            return {"target": target, "average": 0, "minimum": 0, "maximum": 0}
    
    def get_adapter_info(self) -> List[Dict]:
        """Get information about all network adapters"""
        try:
            command = "Get-NetAdapter | Select-Object Name, Status, LinkSpeed, MacAddress | ConvertTo-Json"
            success, output = self.run_powershell(command)
            if success:
                import json
                adapters = json.loads(output)
                if isinstance(adapters, dict):
                    adapters = [adapters]
                return adapters
            return []
        except Exception as e:
            self.log(f"Failed to get adapter info: {e}", "ERROR")
            return []
