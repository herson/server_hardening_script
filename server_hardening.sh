#!/bin/bash

# Server Hardening Script for Linux Systems
# This script disables unnecessary services, modifies SSH configuration, sets up firewall rules,
# installs essential security packages, and applies secure file permissions.

# Make sure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Function to disable unnecessary services
disable_services() {
  echo "Disabling unnecessary services..."
  systemctl stop cups
  systemctl disable cups

  systemctl stop avahi-daemon
  systemctl disable avahi-daemon

  echo "Unnecessary services have been disabled."
}

# Function to secure SSH configuration
secure_ssh() {
  echo "Securing SSH configuration..."
  cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

  # Disable root login and change SSH port to 2222
  sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
  sed -i 's/^#Port 22/Port 2222/' /etc/ssh/sshd_config

  # Restart SSH service
  systemctl restart sshd
  echo "SSH configuration secured and restarted on port 2222."
}

# Function to enable UFW firewall and configure rules
setup_firewall() {
  echo "Setting up the firewall..."
  
  # Install UFW if not installed
  if ! command -v ufw &> /dev/null; then
    apt-get install ufw -y
  fi
  
  ufw allow 2222/tcp   # Allow SSH on port 2222
  ufw allow 80/tcp     # Allow HTTP traffic
  ufw allow 443/tcp    # Allow HTTPS traffic
  ufw default deny incoming
  ufw default allow outgoing
  ufw enable
  
  echo "Firewall has been configured and enabled."
}

# Function to install and configure fail2ban
install_security_packages() {
  echo "Installing security packages (fail2ban and auditd)..."
  
  # Install fail2ban
  apt-get install fail2ban -y

  # Configure fail2ban for SSH
  cat << EOF > /etc/fail2ban/jail.local
[sshd]
enabled = true
port = 2222
logpath = /var/log/auth.log
maxretry = 5
EOF

  systemctl restart fail2ban
  echo "Fail2ban has been configured and restarted."

  # Install and enable auditd for auditing logs
  apt-get install auditd -y
  systemctl start auditd
  systemctl enable auditd
  echo "Auditd has been installed and enabled."
}

# Function to enforce secure file permissions
secure_permissions() {
  echo "Setting secure file permissions for sensitive files..."
  chmod 600 /etc/ssh/sshd_config
  chmod 600 /etc/shadow
  chmod 644 /etc/passwd
  echo "File permissions have been secured."
}

# Function to enforce password policies
enforce_password_policies() {
  echo "Enforcing password complexity and expiration policies..."
  sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
  sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   10/' /etc/login.defs
  sed -i 's/^PASS_MIN_LEN.*/PASS_MIN_LEN    12/' /etc/login.defs
  echo "Password policies have been enforced."
}

# Function to configure automatic security updates
setup_auto_updates() {
  echo "Setting up automatic security updates..."
  
  # Install unattended-upgrades if not installed
  apt-get install unattended-upgrades -y
  dpkg-reconfigure --priority=low unattended-upgrades
  echo "Automatic security updates have been enabled."
}

# Main function to call all hardening steps
main() {
  echo "Starting server hardening process..."

  disable_services
  secure_ssh
  setup_firewall
  install_security_packages
  secure_permissions
  enforce_password_policies
  setup_auto_updates

  echo "Server hardening complete!"
}

# Execute the main function
main
