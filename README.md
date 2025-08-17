# SecureFlow User Management System

A production-ready, enterprise-grade User Management System built with Spring Boot, featuring comprehensive authentication, authorization, user registration, and role-based access control (RBAC).

## 🚀 Overview

**SecureFlow** is a complete user management solution that demonstrates modern Spring Boot best practices for security-focused web applications. It provides a robust foundation for applications requiring user authentication, role-based authorization, and user account management.

### Key Features

- **🔐 Secure Authentication** - BCrypt password encryption with JDBC-based authentication
- **👥 Role-Based Access Control (RBAC)** - Multi-tier authorization system (Employee/Manager/Admin)
- **📝 User Registration** - Complete registration workflow with email validation
- **🎨 Modern UI** - Responsive Thymeleaf templates with clean, professional design
- **🛡️ Security Headers** - CSRF protection, HSTS, XSS protection, and secure session management
- **📊 Production Monitoring** - Spring Boot Actuator integration for health checks and metrics
- **🗄️ PostgreSQL Integration** - Production-ready database with connection pooling
- **✅ Comprehensive Testing** - Automated test scripts for login, registration, and authorization

## 🏗️ Architecture

### Technology Stack

- **Backend Framework**: Spring Boot 3.5.3
- **Security**: Spring Security 6 with JDBC Authentication
- **Template Engine**: Thymeleaf with Spring Security integration
- **Database**: PostgreSQL with Spring Data JPA
- **Connection Pooling**: HikariCP
- **Build Tool**: Maven
- **Java Version**: 17

### Project Structure

```
src/main/java/com/jihan/springboot/usermanagement/
├── controller/          # Web controllers for handling HTTP requests
│   ├── DemoController.java       # Main application pages
│   ├── LoginController.java      # Authentication handling
│   └── RegistrationController.java # User registration
├── dao/                # Data Access Objects
│   ├── RoleDao.java             # Role data operations
│   ├── RoleDaoImpl.java
│   ├── UserDao.java             # User data operations
│   └── UserDaoImpl.java
├── dto/                # Data Transfer Objects
│   ├── UserDto.java             # User data transfer
│   └── UserRegistrationDto.java # Registration form data
├── entity/             # JPA Entities
│   ├── Role.java               # Role entity
│   └── User.java               # User entity with audit fields
├── security/           # Security Configuration
│   ├── CustomAuthenticationSuccessHandler.java
│   └── UserManagementSecurityConfig.java # Main security config
├── service/            # Business Logic Layer
│   ├── UserService.java        # User service interface
│   └── UserServiceImpl.java    # User service implementation
├── exception/          # Exception Handling
│   ├── GlobalExceptionHandler.java
│   ├── UserAlreadyExistsException.java
│   └── UserNotFoundException.java
└── user/               # User-related utilities
    └── WebUser.java            # Web user representation
```

### Database Schema

The application uses PostgreSQL with the following main entities:

- **users** - User accounts with authentication data and profile information
- **roles** - System roles (ROLE_EMPLOYEE, ROLE_MANAGER, ROLE_ADMIN)
- **users_roles** - Many-to-many relationship between users and roles

## 🚀 Getting Started

### Prerequisites

- **Java 17** or higher
- **PostgreSQL 12+** installed and running
- **Maven 3.6+** for building the project

### 1. Database Setup

1. **Create the database**:
   ```sql
   CREATE DATABASE user_management_system;
   ```

2. **Run the schema script**:
   ```bash
   psql -U postgres -d user_management_system -f sql-scripts/fixed-postgresql-schema.sql
   ```

### 2. Configuration

Update database credentials in `src/main/resources/application.properties`:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/user_management_system
spring.datasource.username=your_username
spring.datasource.password=your_password
```

### 3. Build and Run

```bash
# Build the application
./mvnw clean package

# Run the application
./mvnw spring-boot:run
```

### 4. Access the Application

- **Application URL**: http://localhost:8080/user-management
- **Login Page**: http://localhost:8080/user-management/login
- **Registration**: http://localhost:8080/user-management/register/showRegistrationForm
- **Health Check**: http://localhost:8080/user-management/actuator/health

## 👤 Default Test Accounts

| Username | Password | Roles | Access Level |
|----------|----------|-------|--------------|
| `admin` | `password123` | Employee, Manager, Admin | Full system access |
| `manager` | `password123` | Employee, Manager | Home + Leadership pages |
| `employee` | `password123` | Employee | Home page only |

> ⚠️ **Security Notice**: Change these default passwords in production!

## 🔒 Security Features

### Authentication
- **BCrypt Password Encryption** - Industry-standard password hashing
- **JDBC Authentication** - Database-backed user authentication
- **Session Management** - Secure session handling with timeout
- **Login Attempts** - Protection against brute force attacks

### Authorization
- **Role-Based Access Control** - Hierarchical permission system
- **Method-Level Security** - Fine-grained access control
- **URL-Based Security** - Path-specific authorization rules

### Security Headers
- **CSRF Protection** - Cross-Site Request Forgery protection
- **HSTS** - HTTP Strict Transport Security
- **X-Frame-Options** - Clickjacking protection
- **X-Content-Type-Options** - MIME sniffing protection


```

## 📊 Monitoring & Operations

### Health Checks
- **Endpoint**: `/actuator/health`
- **Database Health**: Connection pool status
- **Application Health**: Overall system status

### Metrics
- **Endpoint**: `/actuator/metrics`
- **Custom Metrics**: User registration, login attempts
- **JVM Metrics**: Memory, GC, threads

### Logging
- **Configuration**: Structured logging with configurable levels
- **File Logging**: Rotated log files in `logs/` directory
- **Security Events**: Authentication and authorization logging

## 🔧 Configuration Profiles

### Development (`application-dev.properties`)
- Debug logging enabled
- Thymeleaf cache disabled
- Detailed error messages

### Production (`application-prod.properties`)
- Optimized for performance
- Security headers enforced
- Minimal logging

## 🚀 Deployment

### Traditional Deployment
```bash
# Build production JAR
./mvnw clean package -Pprod

# Run with production profile
java -jar target/user-management-system-1.0.0.jar --spring.profiles.active=prod
```



