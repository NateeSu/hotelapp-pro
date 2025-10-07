-- Fix user passwords for Docker environment
USE hotel_management;

-- Update passwords with correct hashes
UPDATE users SET password_hash = '$2y$10$kax1BzbSErfsaEoRS9o5cuDQPb4MyKzTbLlxmJDA5ge.LWfq4bWBa' WHERE username = 'admin';
UPDATE users SET password_hash = '$2y$10$ITP8utHBKobzU0m/c76iMOt9EPlgwrtrtsQfS8Q3i3V28YK3b8PM6' WHERE username IN ('reception', 'reception1');
UPDATE users SET password_hash = '$2y$10$rEIpC2oYrBiOrsyPhL7CIOueNvn1BPaSQcY7J8B8A0KGH4Mx4CRfy' WHERE username IN ('housekeeping', 'housekeeper1', 'housekeeper2');

-- Verify
SELECT username, 'Updated' as status FROM users;
