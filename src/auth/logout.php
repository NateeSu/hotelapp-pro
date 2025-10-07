<?php
/**
 * Hotel Management System - Logout Page
 *
 * This page handles user logout with CSRF protection and
 * redirects to login page with success message.
 */

// Start output buffering to prevent header issues
ob_start();

// Start session and initialize application
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
date_default_timezone_set('Asia/Bangkok');

// Define base URL
$protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off' ? 'https' : 'http';
$host = $_SERVER['HTTP_HOST'] ?? 'localhost';
$scriptPath = dirname($_SERVER['SCRIPT_NAME']); // /hotel-app
$baseUrl = $protocol . '://' . $host . $scriptPath;
$GLOBALS['baseUrl'] = $baseUrl;

// Load required files (flash.php not needed for logout as it outputs HTML)
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../includes/helpers.php';
require_once __DIR__ . '/../includes/csrf.php';
require_once __DIR__ . '/../includes/auth.php';

// Load flash functions manually without output
if (!function_exists('flash')) {
    function flash($type, $message, $dismissible = true) {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
        $_SESSION['flash'][] = [
            'type' => $type,
            'message' => $message,
            'dismissible' => $dismissible
        ];
    }
}

if (!function_exists('flash_success')) {
    function flash_success($message, $dismissible = true) {
        flash('success', $message, $dismissible);
    }
}

if (!function_exists('flash_info')) {
    function flash_info($message, $dismissible = true) {
        flash('info', $message, $dismissible);
    }
}

// Check if user is logged in
if (!isLoggedIn()) {
    ob_end_clean();
    header('Location: ' . $baseUrl . '/?r=auth.login');
    exit;
}

// Handle POST request (from navbar form)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Verify CSRF token
    require_csrf_token();

    // Get user info before logout
    $user = currentUser();
    $userName = getUserDisplayName($user);

    // Perform logout
    logout();

    // Flash success message
    flash_success("ออกจากระบบเรียบร้อยแล้ว ขอบคุณที่ใช้บริการ {$userName}");

    // Clean buffer and redirect to login
    ob_end_clean();
    header('Location: ' . $baseUrl . '/?r=auth.login');
    exit;
}

// Handle GET request (direct access)
$user = currentUser();
$userName = getUserDisplayName($user);

// Perform logout
logout();

// Flash info message
flash_info("ออกจากระบบเรียบร้อยแล้ว");

// Clean buffer and redirect to login
ob_end_clean();
header('Location: ' . $baseUrl . '/?r=auth.login');
exit;
?>