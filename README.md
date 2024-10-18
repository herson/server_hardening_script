# 🛡️ Server Hardening Script 🛡️

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Script-Bash-blue.svg)](https://www.gnu.org/software/bash/)
![Security](https://img.shields.io/badge/Security-Hardened-green.svg)

🔗 **Repository URL**: [https://github.com/herson/server_hardening_script](https://github.com/herson/server_hardening_script)

## 🚀 Overview

The **Server Hardening Script** is designed to secure your Linux server by disabling unnecessary services, securing SSH access, setting up firewall rules, and configuring automatic security updates. It also installs essential security packages such as `fail2ban` and `auditd`, and enforces strict file permissions and password policies.

This script is ideal for system administrators or anyone looking to improve the security posture of their Linux servers in a quick and automated manner.

---

## 📜 Features

- 🔒 **SSH Hardening**: Disables root login, changes the default SSH port, and sets up `fail2ban` to prevent brute force attacks.
- 🛑 **Disable Unnecessary Services**: Stops and disables services that are often not needed on production servers (e.g., `cups`, `avahi-daemon`).
- 🧱 **Firewall Setup**: Configures `ufw` to only allow necessary traffic on ports 2222 (SSH), 80 (HTTP), and 443 (HTTPS).
- 🔄 **Automated Security Updates**: Sets up automatic security updates to ensure your system stays up-to-date.
- 🛡️ **Security Packages**: Installs and configures `fail2ban` and `auditd` for enhanced security and auditing.
- 🗂️ **File Permissions**: Sets secure permissions for sensitive files like `/etc/ssh/sshd_config` and `/etc/shadow`.
- 🧑‍💻 **Password Policies**: Enforces password complexity and expiration rules.

---

## 📂 Directory Structure

```bash
server_hardening_script/
├── server_hardening.sh    # Main script file
└── README.md              # This file
```

---

## ⚙️ Requirements

- 🐧 **Supported OS**: The script is compatible with most Linux distributions (e.g., Ubuntu, Debian).
- 📦 **Dependencies**: `ufw`, `fail2ban`, `auditd`, `unattended-upgrades` (these are installed automatically by the script if not already available).

---

## 📖 Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/herson/server_hardening_script.git
   cd server_hardening_script
   ```

2. Run the script:

   ```bash
   sudo bash server_hardening.sh
   ```

3. The script will perform the following actions:
   - Disable unnecessary services (`cups`, `avahi-daemon`)
   - Secure SSH by disabling root login and changing the default SSH port to 2222
   - Configure `ufw` firewall rules for SSH (port 2222), HTTP, and HTTPS
   - Install and configure `fail2ban` and `auditd`
   - Enforce secure file permissions
   - Enforce password policies
   - Set up automatic security updates

---

## 🔧 Customization

You can modify the script as needed to suit your environment. For example:
- Change the default SSH port from `2222` to another port.
- Add or remove services to be disabled based on your server’s use case.

---

## 🛠️ Security Considerations

- ⚠️ **Backup your configuration files**: Before running the script, it’s recommended to create backups of important configuration files (e.g., `/etc/ssh/sshd_config`).
- 🔐 **Update the MySQL root password**: After running the script, make sure to secure your MySQL installation if applicable.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/herson/server_hardening_script/blob/main/LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Feel free to submit a pull request, open an issue, or provide feedback.

1. **Fork the project**
2. **Create your feature branch**: ```bash git checkout -b feature/YourFeature ```
3. **Commit your changes**: ```bash git commit -m 'Add your feature' ```
4. **Push to the branch**: ```bash git push origin feature/YourFeature ```
5. **Open a pull request**

---

## 📫 Contact

Created by [Herson Cruz](https://github.com/herson) – feel free to contact me via GitHub if you have any questions!

---

## 🌟 Acknowledgments

Special thanks to the open-source community for making security automation accessible and easy to implement.
