-- User Management System Database Schema
-- Database: user_management_system
-- 
-- Instructions:
-- 1. Create database: CREATE DATABASE user_management_system;
-- 2. Connect to database: \c user_management_system
-- 3. Run this script to create tables and insert sample data

-- Drop tables if they exist
DROP TABLE IF EXISTS users_roles;
DROP TABLE IF EXISTS "user";
DROP TABLE IF EXISTS "role";

--
-- Table structure for table "user"
--
CREATE TABLE "user" (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password CHAR(80) NOT NULL,
    enabled SMALLINT NOT NULL,  
    first_name VARCHAR(64) NOT NULL,
    last_name VARCHAR(64) NOT NULL,
    email VARCHAR(64) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_user_username ON "user"(username);
CREATE INDEX idx_user_email ON "user"(email);

--
-- Insert data into "user"
--
INSERT INTO "user" (username, password, enabled, first_name, last_name, email)
VALUES 
('admin','$2a$04$eFytJDGtjbThXa80FyOOBuFdK2IwjyWefYkMpiBEFlpBwDH.5PM0K',1,'System', 'Administrator', 'admin@usermgmt.com'),
('manager','$2a$04$eFytJDGtjbThXa80FyOOBuFdK2IwjyWefYkMpiBEFlpBwDH.5PM0K',1,'Manager', 'User', 'manager@usermgmt.com'),
('employee','$2a$04$eFytJDGtjbThXa80FyOOBuFdK2IwjyWefYkMpiBEFlpBwDH.5PM0K',1,'Employee', 'User', 'employee@usermgmt.com');

--
-- Table structure for table "role"
--
CREATE TABLE "role" (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- Create index for better performance
CREATE INDEX idx_role_name ON "role"(name);

--
-- Insert data into "role"
--
INSERT INTO "role" (name)
VALUES 
('ROLE_EMPLOYEE'),('ROLE_MANAGER'),('ROLE_ADMIN');

--
-- Table structure for table "users_roles"
--
CREATE TABLE users_roles (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user FOREIGN KEY (user_id)
        REFERENCES "user" (id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT fk_role FOREIGN KEY (role_id)
        REFERENCES "role" (id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

--
-- Insert data into users_roles
--
INSERT INTO users_roles (user_id, role_id)
VALUES 
(1, 1),
(2, 1),
(2, 2),
(3, 1),
(3, 2),
(3, 3);

