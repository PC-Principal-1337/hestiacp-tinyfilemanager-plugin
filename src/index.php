<?php
/**
 * Tiny File Manager - Hestia Integration
 * Security wrapper with automatic login after Hestia authentication
 */

// Start Hestia session
session_start();

// Security check - ensure user is logged in to Hestia
if (!isset($_SESSION['user']) || empty($_SESSION['user'])) {
    header('Location: /login/');
    exit;
}

// Get the logged-in user
$hestia_user = $_SESSION['user'];

// ==============================================
// Tiny File Manager Configuration
// ==============================================

// Set timezone for date/time display
$default_timezone = 'Europe/Berlin';
date_default_timezone_set($default_timezone);

// Root path for file manager
// Users can only access their home directory
define('FM_ROOT_PATH', '/home/' . $hestia_user . '/web');

// Root URL (for downloads, etc.)
define('FM_ROOT_URL', 'http://localhost/');

// Session ID
define('FM_SESSION_ID', 'filemanager');

// Enable authentication
define('FM_USE_AUTH', true);

// Single user setup - the Hestia user
$auth_users = array(
    $hestia_user => '' // Empty password, we handle auth via Hestia
);

// Set the username and password variables (required by Tiny File Manager)
$use_auth = true;
$readonly_users = array();

// IMPORTANT: Automatically log in the Hestia user
// Set Tiny File Manager session to logged in state
if (!isset($_SESSION[FM_SESSION_ID])) {
    $_SESSION[FM_SESSION_ID] = array();
}
$_SESSION[FM_SESSION_ID]['logged'] = $hestia_user;

// Enable CSRF protection
define('FM_CSRF', true);

// Hide system folders and files
define('FM_SHOW_HIDDEN', false);

// Readonly mode - set to true to prevent modifications
define('FM_READONLY', false);

// Enable highlight.js for code syntax highlighting
define('FM_HIGHLIGHTJS_STYLE', 'vs');

// Enable ace.js for code editing
define('FM_EDIT_FILE', true);

// Maximum upload file size (in MB)
define('FM_UPLOAD_MAX_SIZE', 1024);

// File extension for editable files
$GLOBALS['ext_txt'] = 'txt,log,md,css,scss,js,json,xml,html,php,py,yml,yaml,ini,conf,config,htaccess,sh,bash,env,gitignore';

// Allowed file extensions for upload (empty = all allowed)
$GLOBALS['allowed_file_extensions'] = '';

// Sticky Nav bar
$GLOBALS['sticky_navbar'] = true;

// Hide Permissions and Owner cols in file-listing
$GLOBALS['hide_Cols'] = false;

// Theme
$GLOBALS['theme'] = 'light';

// Language
$GLOBALS['lang'] = 'en';

// Error reporting
error_reporting(E_ALL & ~E_NOTICE & ~E_DEPRECATED & ~E_STRICT);
ini_set('display_errors', '0');

// ==============================================
// Load Tiny File Manager
// ==============================================

require_once 'tinyfilemanager.php';
