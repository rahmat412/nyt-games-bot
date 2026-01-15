-- ============================================
-- NYT Games Discord Bot - Docker Init Script
-- ============================================
-- This script runs automatically when MariaDB
-- container starts for the first time.
-- User 'nyt_bot' is created via MYSQL_USER env var.
-- ============================================

-- Create databases
CREATE DATABASE IF NOT EXISTS nyt_wordle;
CREATE DATABASE IF NOT EXISTS nyt_connections;
CREATE DATABASE IF NOT EXISTS nyt_strands;
CREATE DATABASE IF NOT EXISTS nyt_pips;

-- Grant permissions to nyt_bot user (created by MYSQL_USER env var)
-- Note: User is auto-created by MariaDB with MYSQL_USER/MYSQL_PASSWORD
GRANT ALL PRIVILEGES ON nyt_wordle.* TO 'nyt_bot'@'%';
GRANT ALL PRIVILEGES ON nyt_connections.* TO 'nyt_bot'@'%';
GRANT ALL PRIVILEGES ON nyt_strands.* TO 'nyt_bot'@'%';
GRANT ALL PRIVILEGES ON nyt_pips.* TO 'nyt_bot'@'%';
FLUSH PRIVILEGES;

-- ============================================
-- WORDLE TABLES
-- ============================================
CREATE TABLE IF NOT EXISTS nyt_wordle.users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    name VARCHAR(255),
    UNIQUE KEY uq_user_id(user_id)
);

CREATE TABLE IF NOT EXISTS nyt_wordle.entries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    puzzle_id INT NOT NULL,
    user_id BIGINT NOT NULL,
    score INT,
    green INT,
    yellow INT,
    other INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_puzzle_user(puzzle_id, user_id),
    INDEX idx_puzzle_id(puzzle_id),
    INDEX idx_user_id(user_id)
);

-- ============================================
-- CONNECTIONS TABLES
-- ============================================
CREATE TABLE IF NOT EXISTS nyt_connections.users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    name VARCHAR(255),
    UNIQUE KEY uq_user_id(user_id)
);

CREATE TABLE IF NOT EXISTS nyt_connections.entries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    puzzle_id INT NOT NULL,
    user_id BIGINT NOT NULL,
    score INT,
    puzzle_str TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_puzzle_user(puzzle_id, user_id),
    INDEX idx_puzzle_id(puzzle_id),
    INDEX idx_user_id(user_id)
);

-- ============================================
-- STRANDS TABLES
-- ============================================
CREATE TABLE IF NOT EXISTS nyt_strands.users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    name VARCHAR(255),
    UNIQUE KEY uq_user_id(user_id)
);

CREATE TABLE IF NOT EXISTS nyt_strands.entries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    puzzle_id INT NOT NULL,
    user_id BIGINT NOT NULL,
    hints INT,
    puzzle_str TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_puzzle_user(puzzle_id, user_id),
    INDEX idx_puzzle_id(puzzle_id),
    INDEX idx_user_id(user_id)
);

-- ============================================
-- PIPS TABLES
-- ============================================
CREATE TABLE IF NOT EXISTS nyt_pips.users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    name VARCHAR(255),
    UNIQUE KEY uq_user_id(user_id)
);

CREATE TABLE IF NOT EXISTS nyt_pips.entries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    puzzle_id INT NOT NULL,
    user_id BIGINT NOT NULL,
    easy_seconds INT,
    medium_seconds INT,
    hard_seconds INT,
    easy_cookie BOOLEAN,
    medium_cookie BOOLEAN,
    hard_cookie BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_puzzle_user(puzzle_id, user_id),
    INDEX idx_puzzle_id(puzzle_id),
    INDEX idx_user_id(user_id)
);
