#!/bin/bash

# Server Hardening Script for Linux Systems
# This script disables unnecessary services, modifies SSH configuration, sets up firewall rules,
# installs essential security packages, and applies secure file permissions.
# It also includes OS detection, logging, and backup capabilities.

# Variables
LOGFILE="/var/log/server_hardening.log"

# Make sure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Log function
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOGFILE"
}

# Detect OS
detect_os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
  else
    log "Cannot detect OS version. Exiting."
    exit 1
  fi
}

# Function to disable unnecessary services
disable_services() {
  log "Disabling unnecessary services..."

  # Check for services before disabling
  if systemctl is-active --quiet cups; then
    systemctl stop cups && systemctl disable cups
    log "Disabled CUPS service."
  else
    log "CUPS service not found or already disabled."
  fi

  if systemctl is-active --quiet avahi-daemon; then
    systemctl stop avahi-daemon && systemctl disable avahi-daemon
    log "Disabled Avahi-daemon service."
  else
    log "Avahi-daemon service not found or already disabled."
  fi
}

# Function to secure SSH configuration
secure_ssh() {
  log "Securing SSH configuration..."
  cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

  # Disable root login and change SSH port to 2222
  sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
  sed -i 's/^#Port 22/Port 2222/' /etc/ssh/sshd_config

  # Restart SSH service
  systemctl restart sshd && log "SSH configuration secured and restarted on port 2222."
}

# Function to enable UFW firewall and configure rules
setup_firewall() {
  log "Setting up the firewall..."

  # Install UFW if not installed
  if ! command -v ufw &> /dev/null; then
    if [ "$OS" == "debian" ] || [ "$OS" == "ubuntu" ]; then
      apt-get install ufw -y
    elif [ "$OS" == "centos" ] || [ "$OS" == "rhel" ]; then
      yum install ufw -y
    fi
  fi

  ufw allow 2222/tcp   # Allow SSH on port 2222
  ufw allow 80/tcp     # Allow HTTP traffic
  ufw allow 443/tcp    # Allow HTTPS traffic
  ufw default deny incoming
  ufw default allow outgoing
  ufw enable

  log "Firewall has been configured and enabled."
}

# Function to install and configure fail2ban and auditd
install_security_packages() {
  log "Installing security packages (fail2ban and auditd)..."

  # Install packages based on OS
  if [ "$OS" == "debian" ] || [ "$OS" == "ubuntu" ]; then
    apt-get install fail2ban auditd -y
  elif [ "$OS" == "centos" ] || [ "$OS" == "rhel" ]; then
    yum install fail2ban auditd -y
  fi

  # Configure fail2ban for SSH
  cat << EOF > /etc/fail2ban/jail.local
[sshd]
enabled = true
port = 2222
logpath = /var/log/auth.log
maxretry = 5
EOF

  systemctl restart fail2ban && log "Fail2ban configured and restarted."
  systemctl start auditd && systemctl enable auditd && log "Auditd installed and enabled."
}

# Function to enforce secure file permissions
secure_permissions() {
  log "Setting secure file permissions for sensitive files..."
  chmod 600 /etc/ssh/sshd_config
  chmod 600 /etc/shadow
  chmod 644 /etc/passwd
  log "File permissions have been secured."
}

# Function to enforce password policies
enforce_password_policies() {
  log "Enforcing password complexity and expiration policies..."
  sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
  sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   10/' /etc/login.defs
  sed -i 's/^PASS_MIN_LEN.*/PASS_MIN_LEN    12/' /etc/login.defs
  log "Password policies have been enforced."
}

# Function to configure automatic security updates
setup_auto_updates() {
  log "Setting up automatic security updates..."

  if [ "$OS" == "debian" ] || [ "$OS" == "ubuntu" ]; then
    apt-get install unattended-upgrades -y
    dpkg-reconfigure --priority=low unattended-upgrades
  elif [ "$OS" == "centos" ] || [ "$OS" == "rhel" ]; then
    yum install yum-cron -y
    systemctl start yum-cron
    systemctl enable yum-cron
  fi

  log "Automatic security updates have been enabled."
}

# Main function to call all hardening steps
main() {
  log "Starting server hardening process on $(hostname)..."
  
  detect_os
  disable_services
  secure_ssh
  setup_firewall
  install_security_packages
  secure_permissions
  enforce_password_policies
  setup_auto_updates

  log "Server hardening complete!"
}

# Execute the main function
main
