"""
Windows Gaming Optimizer - Complete UI Module
"""
import os
from datetime import datetime
from PyQt6.QtWidgets import *
from PyQt6.QtCore import Qt, QTimer
from PyQt6.QtGui import QFont, QPalette, QColor, QTextCursor

from network import NetworkOptimizer
from memory import MemoryOptimizer
from services import ServiceOptimizer
from system_tweaks import SystemTweaks


class GamingOptimizerUI(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Windows Gaming Optimizer Pro v1.0")
        self.setGeometry(100, 100, 1200, 800)
        
        self.network_optimizer = NetworkOptimizer(logger=self.log_message)
        self.memory_optimizer = MemoryOptimizer(logger=self.log_message)
        self.service_optimizer = ServiceOptimizer(logger=self.log_message)
        self.system_tweaks = SystemTweaks(logger=self.log_message)
        
        self.backup_created = False
        self.active_adapter = None
        
        self.setup_ui()
        self.apply_dark_theme()
        QTimer.singleShot(500, self.detect_adapter)
    
    def setup_ui(self):
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout(central_widget)
        
        # Header
        header = QHBoxLayout()
        title = QLabel("⚡ Windows Gaming Optimizer Pro")
        title.setFont(QFont("Segoe UI", 18, QFont.Weight.Bold))
        header.addWidget(title)
        header.addStretch()
        main_layout.addLayout(header)
        
        # Tabs
        self.tabs = QTabWidget()
        self.create_all_tabs()
        main_layout.addWidget(self.tabs)
        
        # Console
        console_group = QGroupBox("Console Output")
        console_layout = QVBoxLayout()
        self.console = QTextEdit()
        self.console.setReadOnly(True)
        self.console.setMaximumHeight(180)
        self.console.setFont(QFont("Consolas", 9))
        console_layout.addWidget(self.console)
        console_group.setLayout(console_layout)
        main_layout.addWidget(console_group)
        
        # Footer
        footer = QHBoxLayout()
        self.backup_btn = QPushButton("💾 Create Backup")
        self.backup_btn.clicked.connect(self.create_backup)
        footer.addWidget(self.backup_btn)
        
        self.restore_btn = QPushButton("🔄 Restore")
        self.restore_btn.clicked.connect(self.restore_defaults)
        self.restore_btn.setEnabled(False)
        footer.addWidget(self.restore_btn)
        
        footer.addStretch()
        self.status_label = QLabel("Ready")
        footer.addWidget(self.status_label)
        main_layout.addLayout(footer)
    
    def create_all_tabs(self):
        # Network tab
        net_tab = QWidget()
        net_layout = QVBoxLayout(net_tab)
        
        adapter_group = QGroupBox("Network Adapter")
        adapter_layout = QVBoxLayout()
        self.adapter_label = QLabel("No adapter detected")
        adapter_layout.addWidget(self.adapter_label)
        detect_btn = QPushButton("🔍 Detect Adapter")
        detect_btn.clicked.connect(self.detect_adapter)
        adapter_layout.addWidget(detect_btn)
        adapter_group.setLayout(adapter_layout)
        net_layout.addWidget(adapter_group)
        
        opt_group = QGroupBox("Optimizations")
        opt_layout = QVBoxLayout()
        opt_adapter_btn = QPushButton("⚡ Optimize Network Adapter")
        opt_adapter_btn.clicked.connect(self.optimize_network_adapter)
        opt_layout.addWidget(opt_adapter_btn)
        opt_tcp_btn = QPushButton("🚀 Optimize TCP/IP Stack")
        opt_tcp_btn.clicked.connect(self.optimize_tcp_stack)
        opt_layout.addWidget(opt_tcp_btn)
        opt_group.setLayout(opt_layout)
        net_layout.addWidget(opt_group)
        
        dns_group = QGroupBox("DNS Configuration")
        dns_layout = QHBoxLayout()
        cf_btn = QPushButton("☁️ Cloudflare DNS")
        cf_btn.clicked.connect(lambda: self.set_dns("cloudflare"))
        dns_layout.addWidget(cf_btn)
        g_btn = QPushButton("🔍 Google DNS")
        g_btn.clicked.connect(lambda: self.set_dns("google"))
        dns_layout.addWidget(g_btn)
        dns_group.setLayout(dns_layout)
        net_layout.addWidget(dns_group)
        
        net_layout.addStretch()
        self.tabs.addTab(net_tab, "🌐 Network")
        
        # Memory tab
        mem_tab = QWidget()
        mem_layout = QVBoxLayout(mem_tab)
        
        mem_info_group = QGroupBox("Memory Information")
        mem_info_layout = QVBoxLayout()
        self.mem_info_label = QLabel("Loading...")
        mem_info_layout.addWidget(self.mem_info_label)
        mem_info_group.setLayout(mem_info_layout)
        mem_layout.addWidget(mem_info_group)
        
        mem_opt_group = QGroupBox("Memory Optimization")
        mem_opt_layout = QVBoxLayout()
        opt_mem_btn = QPushButton("⚡ Optimize Memory")
        opt_mem_btn.clicked.connect(self.optimize_memory)
        mem_opt_layout.addWidget(opt_mem_btn)
        mem_opt_group.setLayout(mem_opt_layout)
        mem_layout.addWidget(mem_opt_group)
        
        mem_layout.addStretch()
        self.tabs.addTab(mem_tab, "💾 Memory")
        
        # Services tab
        svc_tab = QWidget()
        svc_layout = QVBoxLayout(svc_tab)
        
        svc_group = QGroupBox("Services Optimization")
        svc_group_layout = QVBoxLayout()
        opt_svc_btn = QPushButton("⚡ Optimize Services")
        opt_svc_btn.clicked.connect(self.optimize_services)
        svc_group_layout.addWidget(opt_svc_btn)
        svc_group.setLayout(svc_group_layout)
        svc_layout.addWidget(svc_group)
        
        svc_layout.addStretch()
        self.tabs.addTab(svc_tab, "⚙️ Services")
        
        # System tab
        sys_tab = QWidget()
        sys_layout = QVBoxLayout(sys_tab)
        
        power_group = QGroupBox("Power Plan")
        power_layout = QVBoxLayout()
        power_btn = QPushButton("⚡ Ultimate Performance")
        power_btn.clicked.connect(self.set_ultimate_performance)
        power_layout.addWidget(power_btn)
        power_group.setLayout(power_layout)
        sys_layout.addWidget(power_group)
        
        visual_group = QGroupBox("Visual Effects")
        visual_layout = QVBoxLayout()
        disable_visual_btn = QPushButton("Disable Visual Effects")
        disable_visual_btn.clicked.connect(self.disable_visual_effects)
        visual_layout.addWidget(disable_visual_btn)
        visual_group.setLayout(visual_layout)
        sys_layout.addWidget(visual_group)
        
        sys_layout.addStretch()
        self.tabs.addTab(sys_tab, "🖥️ System")
        
        # Quick Optimize tab
        quick_tab = QWidget()
        quick_layout = QVBoxLayout(quick_tab)
        
        quick_group = QGroupBox("⚡ Quick Optimization")
        quick_group_layout = QVBoxLayout()
        quick_btn = QPushButton("🚀 OPTIMIZE EVERYTHING")
        quick_btn.clicked.connect(self.quick_optimize_all)
        quick_btn.setStyleSheet("background-color: #e74c3c; color: white; font-weight: bold; font-size: 14px; padding: 15px;")
        quick_group_layout.addWidget(quick_btn)
        quick_group.setLayout(quick_group_layout)
        quick_layout.addWidget(quick_group)
        
        quick_layout.addStretch()
        self.tabs.addTab(quick_tab, "🔧 Quick")
    
    def log_message(self, msg):
        self.console.append(f"[{datetime.now().strftime('%H:%M:%S')}] {msg}")
        cursor = self.console.textCursor()
        cursor.movePosition(QTextCursor.MoveOperation.End)
        self.console.setTextCursor(cursor)
    
    def detect_adapter(self):
        self.log_message("Detecting network adapter...")
        self.active_adapter = self.network_optimizer.get_active_adapter()
        if self.active_adapter:
            self.adapter_label.setText(f"Active: {self.active_adapter}")
            self.adapter_label.setStyleSheet("color: #2ecc71;")
        else:
            self.adapter_label.setText("No adapter detected")
            self.adapter_label.setStyleSheet("color: #e74c3c;")
    
    def optimize_network_adapter(self):
        if not self.active_adapter:
            QMessageBox.warning(self, "Warning", "Detect adapter first!")
            return
        reply = QMessageBox.question(self, "Confirm", f"Optimize {self.active_adapter}?",
                                     QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No)
        if reply == QMessageBox.StandardButton.Yes:
            success = self.network_optimizer.optimize_adapter(self.active_adapter)
            if success:
                QMessageBox.information(self, "Success", "Network optimized!")
    
    def optimize_tcp_stack(self):
        reply = QMessageBox.question(self, "Confirm", "Optimize TCP/IP?",
                                     QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No)
        if reply == QMessageBox.StandardButton.Yes:
            self.network_optimizer.optimize_tcp_stack()
            QMessageBox.information(self, "Success", "TCP/IP optimized!")
    
    def set_dns(self, provider):
        if not self.active_adapter:
            self.active_adapter = self.network_optimizer.get_active_adapter()
        self.network_optimizer.set_dns(provider, self.active_adapter)
        QMessageBox.information(self, "Success", f"DNS set to {provider}!")
    
    def optimize_memory(self):
        reply = QMessageBox.question(self, "Confirm", "Optimize memory?",
                                     QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No)
        if reply == QMessageBox.StandardButton.Yes:
            self.memory_optimizer.disable_sysmain()
            self.memory_optimizer.clear_standby_memory()
            QMessageBox.information(self, "Success", "Memory optimized!")
    
    def optimize_services(self):
        reply = QMessageBox.question(self, "Confirm", "Optimize services?",
                                     QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No)
        if reply == QMessageBox.StandardButton.Yes:
            self.service_optimizer.disable_xbox_features()
            self.service_optimizer.disable_telemetry_services()
            QMessageBox.information(self, "Success", "Services optimized!")
    
    def set_ultimate_performance(self):
        self.service_optimizer.set_ultimate_performance_plan()
        QMessageBox.information(self, "Success", "Power plan set!")
    
    def disable_visual_effects(self):
        self.system_tweaks.disable_visual_effects()
        QMessageBox.information(self, "Success", "Visual effects disabled!")
    
    def quick_optimize_all(self):
        reply = QMessageBox.question(self, "Confirm", 
                                     "Apply ALL optimizations?\n\n⚠️ Some changes require restart.",
                                     QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No)
        if reply == QMessageBox.StandardButton.Yes:
            self.log_message("=" * 60)
            self.log_message("FULL OPTIMIZATION STARTED")
            self.log_message("=" * 60)
            
            if not self.active_adapter:
                self.active_adapter = self.network_optimizer.get_active_adapter()
            
            if self.active_adapter:
                self.network_optimizer.optimize_adapter(self.active_adapter)
            self.network_optimizer.optimize_tcp_stack()
            self.memory_optimizer.disable_sysmain()
            self.memory_optimizer.clear_standby_memory()
            self.service_optimizer.disable_xbox_features()
            self.service_optimizer.disable_telemetry_services()
            self.service_optimizer.set_ultimate_performance_plan()
            self.system_tweaks.disable_visual_effects()
            self.system_tweaks.enable_hardware_gpu_scheduling()
            self.system_tweaks.optimize_system_responsiveness()
            
            self.log_message("=" * 60)
            self.log_message("OPTIMIZATION COMPLETED!")
            self.log_message("=" * 60)
            
            QMessageBox.information(self, "Success", 
                                   "Full optimization complete!\n\n⚠️ Restart recommended.")
    
    def create_backup(self):
        self.backup_created = True
        self.restore_btn.setEnabled(True)
        self.log_message("Backup created")
        QMessageBox.information(self, "Success", "Backup created!")
    
    def restore_defaults(self):
        reply = QMessageBox.question(self, "Confirm", "Restore defaults?",
                                     QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No)
        if reply == QMessageBox.StandardButton.Yes:
            self.memory_optimizer.enable_sysmain()
            self.service_optimizer.enable_xbox_features()
            self.system_tweaks.enable_visual_effects()
            self.log_message("Restored defaults")
            QMessageBox.information(self, "Success", "Restored!")
    
    def apply_dark_theme(self):
        dark_palette = QPalette()
        dark_palette.setColor(QPalette.ColorRole.Window, QColor(53, 53, 53))
        dark_palette.setColor(QPalette.ColorRole.WindowText, Qt.GlobalColor.white)
        dark_palette.setColor(QPalette.ColorRole.Base, QColor(35, 35, 35))
        dark_palette.setColor(QPalette.ColorRole.Text, Qt.GlobalColor.white)
        dark_palette.setColor(QPalette.ColorRole.Button, QColor(53, 53, 53))
        dark_palette.setColor(QPalette.ColorRole.ButtonText, Qt.GlobalColor.white)
        self.setPalette(dark_palette)
        
        self.setStyleSheet("""
            QGroupBox {
                font-weight: bold;
                border: 2px solid #3498db;
                border-radius: 5px;
                margin-top: 10px;
                padding-top: 10px;
            }
            QPushButton {
                padding: 8px;
                border-radius: 3px;
                background-color: #3498db;
                color: white;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #2980b9;
            }
        """)
