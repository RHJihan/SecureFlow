-- =============================================================================
-- Fixed User Management System Database Schema for PostgreSQL
-- =============================================================================
-- Database: user_management_system
-- 
-- Fixed Issues:
-- 1. Removed quotes from table names to avoid case-sensitivity issues
-- 2. Updated table names to match JPA entities (users, roles)
-- 
-- Prerequisites:
-- 1. PostgreSQL must be installed and running
-- 2. Create database: CREATE DATABASE user_management_system;
-- 3. Connect to database: \c user_management_system;
-- 4. Run this script to create tables and insert sample data
-- 
-- Author: Generated for Spring Boot User Management System
-- Version: 1.0.1 (Fixed)
-- Compatible with: PostgreSQL 12+
-- =============================================================================

-- Set client encoding and timezone
SET client_encoding = 'UTF8';
SET timezone = 'UTC';

-- Enable uuid extension if needed for future use
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop existing tables and constraints (in reverse dependency order)
DROP TABLE IF EXISTS users_roles CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS roles CASCADE;

-- Drop the old quoted tables if they exist
DROP TABLE IF EXISTS "user" CASCADE;
DROP TABLE IF EXISTS "role" CASCADE;

-- Drop existing sequences (will be recreated automatically)
DROP SEQUENCE IF EXISTS roles_id_seq CASCADE;
DROP SEQUENCE IF EXISTS users_id_seq CASCADE;
DROP SEQUENCE IF EXISTS role_id_seq CASCADE;
DROP SEQUENCE IF EXISTS user_id_seq CASCADE;

-- =============================================================================
-- Table: roles
-- Purpose: Stores user roles for authorization (RBAC)
-- =============================================================================
CREATE TABLE roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    
    -- Metadata
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_role_name_not_empty CHECK (LENGTH(TRIM(name)) > 0),
    CONSTRAINT chk_role_name_format CHECK (name ~ '^ROLE_[A-Z_]+$')
);

-- Indexes for roles table
CREATE INDEX idx_role_name ON roles(name);
CREATE INDEX idx_role_created_at ON roles(created_at);

-- Comment on roles table
COMMENT ON TABLE roles IS 'User roles for role-based access control (RBAC)';
COMMENT ON COLUMN roles.id IS 'Unique identifier for the role';
COMMENT ON COLUMN roles.name IS 'Role name following ROLE_* convention';
COMMENT ON COLUMN roles.created_at IS 'Timestamp when the role was created';
COMMENT ON COLUMN roles.updated_at IS 'Timestamp when the role was last updated';

-- =============================================================================
-- Table: users
-- Purpose: Stores user account information and authentication data
-- =============================================================================
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(80) NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT true,
    first_name VARCHAR(64) NOT NULL,
    last_name VARCHAR(64) NOT NULL,
    email VARCHAR(64) NOT NULL UNIQUE,
    
    -- Audit fields
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_username_length CHECK (LENGTH(TRIM(username)) BETWEEN 3 AND 50),
    CONSTRAINT chk_username_format CHECK (username ~ '^[a-zA-Z0-9._-]+$'),
    CONSTRAINT chk_password_not_empty CHECK (LENGTH(TRIM(password)) > 0),
    CONSTRAINT chk_first_name_not_empty CHECK (LENGTH(TRIM(first_name)) > 0),
    CONSTRAINT chk_last_name_not_empty CHECK (LENGTH(TRIM(last_name)) > 0),
    CONSTRAINT chk_email_format CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Indexes for users table (matching JPA entity annotations)
CREATE INDEX idx_user_username ON users(username);
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_user_enabled ON users(enabled);
CREATE INDEX idx_user_created_at ON users(created_at);
CREATE INDEX idx_user_full_name ON users(first_name, last_name);

-- Comment on users table
COMMENT ON TABLE users IS 'User accounts with authentication and profile information';
COMMENT ON COLUMN users.id IS 'Unique identifier for the user';
COMMENT ON COLUMN users.username IS 'Unique username for login (3-50 chars, alphanumeric)';
COMMENT ON COLUMN users.password IS 'Encrypted password (BCrypt recommended)';
COMMENT ON COLUMN users.enabled IS 'Account status - true if active, false if disabled';
COMMENT ON COLUMN users.first_name IS 'User first name';
COMMENT ON COLUMN users.last_name IS 'User last name';
COMMENT ON COLUMN users.email IS 'Unique email address';
COMMENT ON COLUMN users.created_at IS 'Account creation timestamp';
COMMENT ON COLUMN users.updated_at IS 'Last modification timestamp';

-- =============================================================================
-- Table: users_roles
-- Purpose: Many-to-many relationship between users and roles
-- =============================================================================
CREATE TABLE users_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    
    -- Audit fields
    assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assigned_by VARCHAR(50),
    
    -- Primary key
    PRIMARY KEY (user_id, role_id),
    
    -- Foreign key constraints
    CONSTRAINT fk_users_roles_user 
        FOREIGN KEY (user_id) REFERENCES users(id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_users_roles_role 
        FOREIGN KEY (role_id) REFERENCES roles(id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Indexes for users_roles table
CREATE INDEX idx_users_roles_user_id ON users_roles(user_id);
CREATE INDEX idx_users_roles_role_id ON users_roles(role_id);
CREATE INDEX idx_users_roles_assigned_at ON users_roles(assigned_at);

-- Comment on users_roles table
COMMENT ON TABLE users_roles IS 'Many-to-many relationship between users and roles';
COMMENT ON COLUMN users_roles.user_id IS 'Reference to users.id';
COMMENT ON COLUMN users_roles.role_id IS 'Reference to roles.id';
COMMENT ON COLUMN users_roles.assigned_at IS 'When the role was assigned to the user';
COMMENT ON COLUMN users_roles.assigned_by IS 'Who assigned the role (optional)';

-- =============================================================================
-- TRIGGERS FOR AUTOMATIC TIMESTAMP UPDATES
-- =============================================================================

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger for roles table
CREATE TRIGGER update_role_updated_at 
    BEFORE UPDATE ON roles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for users table
CREATE TRIGGER update_user_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- INSERT SAMPLE DATA
-- =============================================================================

-- Insert roles (following Spring Security convention)
INSERT INTO roles (name) VALUES 
    ('ROLE_EMPLOYEE'),
    ('ROLE_MANAGER'),
    ('ROLE_ADMIN'),
    ('ROLE_SUPER_ADMIN');

-- Insert sample users with BCrypt encrypted passwords
-- Note: All passwords are "password123" encrypted with BCrypt
-- You should change these passwords in production!
INSERT INTO users (username, password, enabled, first_name, last_name, email) VALUES 
    (
        'admin',
        '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj8w8W7K6N.C',
        true,
        'System',
        'Administrator',
        'admin@usermgmt.com'
    ),
    (
        'manager',
        '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj8w8W7K6N.C',
        true,
        'Manager',
        'User',
        'manager@usermgmt.com'
    ),
    (
        'employee',
        '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj8w8W7K6N.C',
        true,
        'Employee',
        'User',
        'employee@usermgmt.com'
    ),
    (
        'john.doe',
        '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj8w8W7K6N.C',
        true,
        'John',
        'Doe',
        'john.doe@usermgmt.com'
    );

-- Assign roles to users
-- Admin user gets all roles
INSERT INTO users_roles (user_id, role_id, assigned_by) VALUES 
    (1, 1, 'SYSTEM'), -- admin -> ROLE_EMPLOYEE
    (1, 2, 'SYSTEM'), -- admin -> ROLE_MANAGER
    (1, 3, 'SYSTEM'), -- admin -> ROLE_ADMIN
    (1, 4, 'SYSTEM'); -- admin -> ROLE_SUPER_ADMIN

-- Manager user gets employee and manager roles
INSERT INTO users_roles (user_id, role_id, assigned_by) VALUES 
    (2, 1, 'SYSTEM'), -- manager -> ROLE_EMPLOYEE
    (2, 2, 'SYSTEM'); -- manager -> ROLE_MANAGER

-- Employee user gets only employee role
INSERT INTO users_roles (user_id, role_id, assigned_by) VALUES 
    (3, 1, 'SYSTEM'); -- employee -> ROLE_EMPLOYEE

-- John Doe gets employee role
INSERT INTO users_roles (user_id, role_id, assigned_by) VALUES 
    (4, 1, 'SYSTEM'); -- john.doe -> ROLE_EMPLOYEE

-- =============================================================================
-- UTILITY VIEWS FOR COMMON QUERIES
-- =============================================================================

-- View for user details with roles
CREATE OR REPLACE VIEW user_roles_view AS
SELECT 
    u.id as user_id,
    u.username,
    u.email,
    u.first_name,
    u.last_name,
    u.enabled,
    u.created_at as user_created_at,
    r.id as role_id,
    r.name as role_name,
    ur.assigned_at as role_assigned_at
FROM users u
LEFT JOIN users_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
ORDER BY u.username, r.name;

-- View for active users only
CREATE OR REPLACE VIEW active_users_view AS
SELECT 
    id,
    username,
    first_name,
    last_name,
    email,
    created_at,
    updated_at
FROM users
WHERE enabled = true
ORDER BY username;

-- =============================================================================
-- PERFORMANCE OPTIMIZATION
-- =============================================================================

-- Analyze tables for query optimization
ANALYZE roles;
ANALYZE users;
ANALYZE users_roles;

-- =============================================================================
-- VERIFICATION QUERIES
-- =============================================================================

-- Verify table creation
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name IN ('users', 'roles', 'users_roles')
ORDER BY table_name;

-- Verify data insertion
SELECT 
    'Users' as entity_type,
    COUNT(*) as count
FROM users
UNION ALL
SELECT 
    'Roles' as entity_type,
    COUNT(*) as count
FROM roles
UNION ALL
SELECT 
    'User-Role Assignments' as entity_type,
    COUNT(*) as count
FROM users_roles;

-- Show users with their roles
SELECT 
    u.username,
    u.email,
    u.enabled,
    STRING_AGG(r.name, ', ' ORDER BY r.name) as roles
FROM users u
LEFT JOIN users_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
GROUP BY u.id, u.username, u.email, u.enabled
ORDER BY u.username;

-- =============================================================================
-- NOTES
-- =============================================================================

/*
FIXES APPLIED:
1. Changed table names from "user" and "role" to users and roles (removed quotes)
2. Updated all references to use the new table names
3. This resolves the PostgreSQL case-sensitivity issue with quoted identifiers

DEFAULT CREDENTIALS (CHANGE IN PRODUCTION):
- admin/password123 (All roles)
- manager/password123 (Employee, Manager roles)  
- employee/password123 (Employee role only)
- john.doe/password123 (Employee role only)

HIBERNATE COMPATIBILITY:
- Table names now match JPA @Table annotations
- No quoted identifiers to cause case-sensitivity issues
- Standard PostgreSQL naming conventions
*/
