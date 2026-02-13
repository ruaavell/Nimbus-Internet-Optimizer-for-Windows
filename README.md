🚀 Nimbus Optimizer

Nimbus Optimizer is a Windows 10/11 command-line performance optimization tool designed specifically for competitive gaming.

It focuses on:

Lower system latency

Reduced background overhead

Network stack optimization

Stable frametimes

Clean and reversible system tweaks

No fake “FPS boost” claims.
Only real Windows-level optimizations.

⚙️ Features
🌐 Network Optimization

Disable Interrupt Moderation

Disable Energy Efficient Ethernet

Disable Large Send Offload (IPv4/IPv6)

Disable Receive Side Coalescing

Disable Flow Control

Optimize TCP stack via netsh

DNS switch:

Cloudflare (1.1.1.1 / 1.0.0.1)

Google (8.8.8.8 / 8.8.4.4)

DNS flush

Optional Winsock reset

Before/After latency test

🧠 Memory Optimization

Disable SysMain (Superfetch)

Optional Windows Search disable

Clear standby memory

Remove unnecessary startup items

🧹 Background Process Control

Detect high CPU background processes

Kill non-critical processes (user-confirmed)

Disable Xbox Game Bar

Disable Game DVR

Temporarily stop update services

🔥 Windows Performance Tweaks

Enable Ultimate Performance power plan

Disable Fullscreen Optimization

Enable Hardware-Accelerated GPU Scheduling (if supported)

Disable visual effects (Best Performance mode)

Disable telemetry services

🛡 Safety

Requires Administrator privileges

Automatic registry backup before changes

Full restore-to-default option

Modular and reversible architecture

No third-party binaries

No anti-cheat violation behavior

Nimbus Optimizer does NOT inject into games.
It only modifies Windows configuration.

🧪 Example Usage
python main.py --network-optimize
python main.py --ram-optimize
python main.py --disable-telemetry
python main.py --restore-defaults

⚠️ Disclaimer

This tool modifies Windows system settings.
Use at your own risk.

Always create a system restore point before applying aggressive optimizations.

🎯 Philosophy

Competitive gaming performance comes from:

Low DPC latency

Stable network stack

Reduced OS overhead

Clean startup environment

Nimbus Optimizer focuses on these fundamentals.

📄 License

MIT License
