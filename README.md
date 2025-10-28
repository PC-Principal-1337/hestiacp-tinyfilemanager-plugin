# TinyFileManager Plugin for HestiaCP

**Easy-to-install file manager plugin** that integrates TinyFileManager seamlessly into Hestia Control Panel.

## Why This Plugin?

- **3-Command Installation** - Get a modern file manager in under 2 minutes
- **No Configuration Needed** - Automatic authentication and setup
- **Update-Safe** - Patch-based architecture that works with Hestia updates
- **Professional Features** - Everything you expect from a modern file manager

## Features

- **Seamless Hestia Integration**: Automatic authentication using Hestia sessions - no separate login
- **Multi-Tenancy Support**: Each Hestia user sees only their own domains and files
- **Smart Public File Detection**: "Open in Browser" button only appears for publicly accessible files
- **Multiple Public Directory Support**: Works with `public_html`, `public_shtml`, `httpdocs`, and `www`
- **Webspace-Only Access**: Users restricted to their `/web` directory (like Plesk)
- **Full File Management**: Create, edit, upload, download, zip/unzip files
- **Code Editor**: Syntax highlighting with Ace editor
- **Dark Mode**: Customizable theme and persistent settings
- **Secure**: Proper ACL permissions and user isolation
- **UI Integration**: File Manager buttons in domain list + global navigation

## Requirements

- Hestia Control Panel (tested on v1.8+)
- PHP 7.4 or higher
- ACL support on filesystem

## Installation

### Quick Install (3 commands)

```bash
wget https://raw.githubusercontent.com/PC-Principal-1337/hestiacp-tinyfilemanager-plugin/main/install.sh
chmod +x install.sh
sudo ./install.sh
```

That's it! Access at `https://your-server:8083/filemanager/`

### What the Installer Does

1. Downloads latest TinyFileManager from official repo
2. Applies HestiaCP integration patches
3. Installs authentication wrapper
4. Sets up ACL permissions for all users
5. Patches Hestia UI for seamless integration

### Manual Installation

If you prefer to understand what's happening:

```bash
git clone https://github.com/PC-Principal-1337/hestiacp-tinyfilemanager-plugin.git
cd hestiacp-tinyfilemanager-plugin
sudo ./install.sh
```

The installer will:
- Create `/usr/local/hestia/web/filemanager/` (isolated, no conflicts)
- Apply patches with dry-run validation
- Create automatic backups before patching
- Show clear errors if patches fail

## How It Works

This is a **plugin**, not a fork:

- **No code duplication** - TinyFileManager is downloaded during installation
- **Patch-based** - Your Hestia installation is safely modified
- **Isolated** - Installed only for Hestia, doesn't affect user's own file managers
- **Update-safe** - Works with Hestia updates (patches fail gracefully if structure changed)

### Architecture

```
Original TinyFileManager (downloaded)
         ↓
   + Patches (our features)
         ↓
   + Hestia Auth Wrapper
         ↓
TinyFileManager for HestiaCP
```

## Key Differences from Standard TinyFileManager

1. **Automatic Hestia Authentication** - No separate login required
2. **User Isolation** - Each user restricted to their `/web` directory
3. **Smart URL Generation** - Public files show correct `https://domain.com/file.html` URLs
4. **Multi-Directory Support** - Works with various public directory naming conventions
5. **Persistent Settings** - Theme and preferences saved in `config.php`
6. **Clickable Title** - "File Manager" text acts as home button
7. **UI Integration** - Buttons in Hestia domain list and global navigation

## Security

- Users cannot access files outside their `/web` directory
- ACL permissions ensure proper file access control
- CSRF protection enabled
- Automatic user isolation via Hestia sessions
- No impact on existing TinyFileManager installations

## Troubleshooting

### Files not visible

Check ACL permissions:
```bash
sudo getfacl /home/admin/web/domain.com
```
Should show `user:hestiaweb:rwx`

### Cannot save files (Error 500)

Ensure config.php exists and is writable:
```bash
ls -la /usr/local/hestia/web/filemanager/config.php
```
Should be owned by `hestiaweb:hestiaweb`

### Patches failed during installation

The installer shows clear warnings if patches don't apply. This usually means:
- Hestia or TinyFileManager version changed
- Check installer output for manual edit instructions
- File backups are created automatically

## Uninstallation

```bash
sudo ./uninstall.sh
```

Or manually:
```bash
sudo rm -rf /usr/local/hestia/web/filemanager
```

## Contributing

Contributions welcome! This is a community plugin.

1. Fork this repository
2. Create a feature branch
3. Test your changes
4. Submit a pull request

## Credits

- [TinyFileManager](https://github.com/prasathmani/tinyfilemanager) by Prasath Mani
- [Hestia Control Panel](https://github.com/hestiacp/hestiacp)

## License

GPL v3 - Same as Hestia Control Panel

## Support

- [Open an issue](https://github.com/PC-Principal-1337/hestiacp-tinyfilemanager-plugin/issues)
- [Hestia Forum](https://forum.hestiacp.com/)
