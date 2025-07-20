#!/bin/bash

# Comprehensive Boot Performance Investigation Script
# Analyzes ECS Optimized AMI (Amazon Linux 2023) boot performance

echo "=== ECS Optimized AMI Boot Performance Investigation ==="
echo "Timestamp: $(date)"
echo "Instance Type: $(curl -s http://169.254.169.254/latest/meta-data/instance-type)"
echo "AMI ID: $(curl -s http://169.254.169.254/latest/meta-data/ami-id)"
echo "Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
echo "Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)"
echo ""

echo "=== System Information ==="
echo "Kernel Version: $(uname -r)"
echo "OS Release:"
cat /etc/os-release | head -5
echo ""
echo "Uptime: $(uptime)"
echo "Load Average: $(cat /proc/loadavg)"
echo ""

echo "=== Boot Time Analysis ==="
echo "System Boot Time:"
systemd-analyze
echo ""

echo "Detailed Boot Timing:"
systemd-analyze blame | head -20
echo ""

echo "Critical Chain Analysis:"
systemd-analyze critical-chain
echo ""

echo "=== Systemd Service Status ==="
echo "Failed Services:"
systemctl --failed --no-pager
echo ""

echo "Slow Starting Services (>5 seconds):"
systemd-analyze blame | awk '$1 ~ /[0-9]+s/ && $1 !~ /ms/ { if ($1+0 > 5) print $0 }' | head -10
echo ""

echo "=== Kernel Boot Messages (dmesg) ==="
echo "Boot-related messages:"
dmesg | grep -E "(Freeing|Mount|Loading|Starting|Reached|Failed)" | head -20
echo ""

echo "Error/Warning messages:"
dmesg | grep -E "(error|Error|ERROR|warn|Warn|WARN|fail|Fail|FAIL)" | head -15
echo ""

echo "Timing-related messages:"
dmesg | grep -E "(\[[0-9]+\.[0-9]+\])" | tail -20
echo ""

echo "=== ECS Agent Status ==="
echo "ECS Agent Service Status:"
systemctl status ecs --no-pager -l
echo ""

echo "ECS Agent Logs (last 20 lines):"
journalctl -u ecs --no-pager -n 20
echo ""

echo "=== Docker Status ==="
echo "Docker Service Status:"
systemctl status docker --no-pager -l
echo ""

echo "Docker Version:"
docker --version 2>/dev/null || echo "Docker not available"
echo ""

echo "=== Network Configuration ==="
echo "Network Interfaces:"
ip addr show | grep -E "(inet |UP|DOWN)"
echo ""

echo "DNS Configuration:"
cat /etc/resolv.conf
echo ""

echo "=== Storage Performance ==="
echo "Disk Usage:"
df -h
echo ""

echo "I/O Statistics:"
iostat -x 1 3 2>/dev/null || echo "iostat not available"
echo ""

echo "=== Memory Usage ==="
echo "Memory Information:"
free -h
echo ""

echo "Memory-related kernel messages:"
dmesg | grep -i memory | tail -10
echo ""

echo "=== Process Analysis ==="
echo "Top CPU consuming processes:"
ps aux --sort=-%cpu | head -10
echo ""

echo "Top Memory consuming processes:"
ps aux --sort=-%mem | head -10
echo ""

echo "=== Cloud-Init Analysis ==="
echo "Cloud-init status:"
cloud-init status 2>/dev/null || echo "cloud-init status not available"
echo ""

echo "Cloud-init timing:"
cat /var/log/cloud-init.log 2>/dev/null | grep -E "(took|seconds|finished)" | tail -10 || echo "cloud-init logs not accessible"
echo ""

echo "=== Journal Analysis ==="
echo "Boot messages from journal:"
journalctl -b --no-pager | grep -E "(Started|Reached|Failed)" | head -15
echo ""

echo "Slow services from journal:"
journalctl -b --no-pager | grep -E "([0-9]+s|[0-9]+ms)" | grep -v "0ms" | head -10
echo ""

echo "=== Hardware Information ==="
echo "CPU Information:"
lscpu | grep -E "(Model name|CPU\(s\)|Thread|Core)"
echo ""

echo "Block Devices:"
lsblk
echo ""

echo "=== Performance Recommendations ==="
echo ""
echo "Analysis Summary:"
echo "1. Boot Time: $(systemd-analyze | grep 'Startup finished' | awk '{print $4}')"
echo "2. Kernel Time: $(systemd-analyze | grep 'Startup finished' | awk '{print $2}')"
echo "3. Userspace Time: $(systemd-analyze | grep 'Startup finished' | awk '{print $3}')"
echo ""

echo "Top 5 Slowest Services:"
systemd-analyze blame | head -5
echo ""

echo "=== Investigation Complete ==="
echo "Timestamp: $(date)"
