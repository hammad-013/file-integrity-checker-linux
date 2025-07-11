# 🔐 File Integrity Checker for Linux

A lightweight, Linux CLI tool written in Bash to monitor file integrity using SHA-256 hashes.

## 🧠 What It Does

- Detects file changes (modified, deleted, added)
- Stores hashes securely in `~/.fic/`
- Verifies integrity using controlled read/write access
- Shows summary of changes
- Easy to use with clear CLI interface

## 🖥️ Usage

```bash
chmod +x integrity.sh

# Initialize a folder
./integrity.sh init /path/to/folder

# Scan the folder later for changes
./integrity.sh scan /path/to/folder

# Help & version
./integrity.sh --help
./integrity.sh --version
