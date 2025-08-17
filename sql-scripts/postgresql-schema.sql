-- =============================================================================
-- User Management System Database Schema for PostgreSQL
-- =============================================================================
-- Database: user_management_system
-- 
-- Prerequisites:
-- 1. PostgreSQL must be installed and running
-- 2. Create database: CREATE DATABASE user_management_system;
-- 3. Connect to database: \c user_management_system;
-- 4. Run this script to create tables and insert sample data
-- 
-- Author: Generated for Spring Boot User Management System
-- Version: 1.0.0
-- Compatible with: PostgreSQL 12+
-- =============================================================================

-- Set client encoding and timezone
SET client_encoding = 'UTF8';
SET timezone = 'UTC';

-- Enable uuid extension if needed for future use
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop existing tables and constraints (in reverse dependency order)
DROP TABLE IF EXISTS users_roles CASCADE;
DROP TABLE IF EXISTS "user" CASCADE;
DROP TABLE IF EXISTS "role" CASCADE;

-- Drop existing sequences (will be recreated automatically)
DROP SEQUENCE IF EXISTS role_id_seq CASCADE;
DROP SEQUENCE IF EXISTS user_id_seq CASCADE;

-- =============================================================================
-- Table: role
-- Purpose: Stores user roles for authorization (RBAC)
-- =============================================================================
CREATE TABLE "role" (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    
    -- Metadata
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_role_name_not_empty CHECK (LENGTH(TRIM(name)) > 0),
    CONSTRAINT chk_role_name_format CHECK (name ~ '^ROLE_[A-Z_]+$')
);

-- Indexes for role table
CREATE INDEX idx_role_name ON "role"(name);
CREATE INDEX idx_role_created_at ON "role"(created_at);

-- Comment on role table
COMMENT ON TABLE "role" IS 'User roles for role-based access control (RBAC)';
COMMENT ON COLUMN "role".id IS 'Unique identifier for the role';
COMMENT ON COLUMN "role".name IS 'Role name following ROLE_* convention';
COMMENT ON COLUMN "role".created_at IS 'Timestamp when the role was created';
COMMENT ON COLUMN "role".updated_at IS 'Timestamp when the role was last updated';

-- =============================================================================
-- Table: user
-- Purpose: Stores user account information and authentication data
-- =============================================================================
CREATE TABLE "user" (
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

-- Indexes for user table (matching JPA entity annotations)
CREATE INDEX idx_user_username ON "user"(username);
CREATE INDEX idx_user_email ON "user"(email);
CREATE INDEX idx_user_enabled ON "user"(enabled);
CREATE INDEX idx_user_created_at ON "user"(created_at);
CREATE INDEX idx_user_full_name ON "user"(first_name, last_name);

-- Comment on user table
COMMENT ON TABLE "user" IS 'User accounts with authentication and profile information';
COMMENT ON COLUMN "user".id IS 'Unique identifier for the user';
COMMENT ON COLUMN "user".username IS 'Unique username for login (3-50 chars, alphanumeric)';
COMMENT ON COLUMN "user".password IS 'Encrypted password (BCrypt recommended)';
COMMENT ON COLUMN "user".enabled IS 'Account status - true if active, false if disabled';
COMMENT ON COLUMN "user".first_name IS 'User first name';
COMMENT ON COLUMN "user".last_name IS 'User last name';
COMMENT ON COLUMN "user".email IS 'Unique email address';
COMMENT ON COLUMN "user".created_at IS 'Account creation timestamp';
COMMENT ON COLUMN "user".updated_at IS 'Last modification timestamp';

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
        FOREIGN KEY (user_id) REFERENCES "user"(id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_users_roles_role 
        FOREIGN KEY (role_id) REFERENCES "role"(id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Indexes for users_roles table
CREATE INDEX idx_users_roles_user_id ON users_roles(user_id);
CREATE INDEX idx_users_roles_role_id ON users_roles(role_id);
CREATE INDEX idx_users_roles_assigned_at ON users_roles(assigned_at);

-- Comment on users_roles table
COMMENT ON TABLE users_roles IS 'Many-to-many relationship between users and roles';
COMMENT ON COLUMN users_roles.user_id IS 'Reference to user.id';
COMMENT ON COLUMN users_roles.role_id IS 'Reference to role.id';
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

-- Trigger for role table
CREATE TRIGGER update_role_updated_at 
    BEFORE UPDATE ON "role" 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for user table
CREATE TRIGGER update_user_updated_at 
    BEFORE UPDATE ON "user" 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- INSERT SAMPLE DATA
-- =============================================================================

-- Insert roles (following Spring Security convention)
INSERT INTO "role" (name) VALUES 
    ('ROLE_EMPLOYEE'),
    ('ROLE_MANAGER'),
    ('ROLE_ADMIN'),
    ('ROLE_SUPER_ADMIN');

-- Insert sample users with BCrypt encrypted passwords
-- Note: All passwords are "password123" encrypted with BCrypt
-- You should change these passwords in production!
INSERT INTO "user" (username, password, enabled, first_name, last_name, email) VALUES 
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
FROM "user" u
LEFT JOIN users_roles ur ON u.id = ur.user_id
LEFT JOIN "role" r ON ur.role_id = r.id
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
FROM "user"
WHERE enabled = true
ORDER BY username;

-- =============================================================================
-- SECURITY CONSIDERATIONS
-- =============================================================================

-- Create application user (recommended for production)
-- DO NOT GRANT SUPERUSER PRIVILEGES IN PRODUCTION!

-- Example commands (uncomment and modify as needed):
-- CREATE USER app_user WITH PASSWORD 'your_secure_password_here';
-- GRANT CONNECT ON DATABASE user_management_system TO app_user;
-- GRANT USAGE ON SCHEMA public TO app_user;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- =============================================================================
-- PERFORMANCE OPTIMIZATION
-- =============================================================================

-- Analyze tables for query optimization
ANALYZE "role";
ANALYZE "user";
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
    AND table_name IN ('user', 'role', 'users_roles')
ORDER BY table_name;

-- Verify data insertion
SELECT 
    'Users' as entity_type,
    COUNT(*) as count
FROM "user"
UNION ALL
SELECT 
    'Roles' as entity_type,
    COUNT(*) as count
FROM "role"
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
FROM "user" u
LEFT JOIN users_roles ur ON u.id = ur.user_id
LEFT JOIN "role" r ON ur.role_id = r.id
GROUP BY u.id, u.username, u.email, u.enabled
ORDER BY u.username;

-- =============================================================================
-- NOTES
-- =============================================================================

/*
1. Default Credentials (CHANGE IN PRODUCTION):
   - admin/password123 (All roles)
   - manager/password123 (Employee, Manager roles)
   - employee/password123 (Employee role only)
   - john.doe/password123 (Employee role only)

2. Password Encryption:
   - Uses BCrypt with strength 12
   - Always hash passwords in your application before storing

3. Database Naming:
   - Tables use double quotes to handle PostgreSQL reserved words
   - Column names follow snake_case convention
   - Constraints have descriptive names

4. Performance:
   - Indexes created on frequently queried columns
   - Foreign keys with CASCADE for referential integrity
   - Automatic timestamp updates via triggers

5. Security:
   - Email and username validation via CHECK constraints
   - Password field sized for BCrypt hashes
   - Proper foreign key relationships

6. Extensibility:
   - UUID extension enabled for future use
   - Audit fields in junction table
   - Utility views for common queries
*/

