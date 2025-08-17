package com.jihan.springboot.usermanagement.service;

import com.jihan.springboot.usermanagement.dto.UserDto;
import com.jihan.springboot.usermanagement.dto.UserRegistrationDto;
import com.jihan.springboot.usermanagement.entity.User;
import com.jihan.springboot.usermanagement.user.WebUser;
import org.springframework.security.core.userdetails.UserDetailsService;

import java.util.List;

/**
 * Service interface for User management operations
 * 
 * This service handles all user-related business logic including
 * user registration, authentication, and user management.
 * 
 * @author Jihan
 * @version 1.0.0
 */
public interface UserService extends UserDetailsService {

    /**
     * Find user by username
     * @param userName the username to search for
     * @return User entity or null if not found
     */
    User findByUserName(String userName);

    /**
     * Save a new user from web registration form
     * @param webUser the user data from web form
     * @deprecated Use {@link #save(UserRegistrationDto)} instead
     */
    @Deprecated
    void save(WebUser webUser);

    /**
     * Save a new user from registration DTO
     * @param userRegistrationDto the user registration data
     * @return the saved user as DTO
     */
    UserDto save(UserRegistrationDto userRegistrationDto);

    /**
     * Get all users
     * @return list of user DTOs
     */
    List<UserDto> findAllUsers();

    /**
     * Find user by ID
     * @param id the user ID
     * @return user DTO or null if not found
     */
    UserDto findById(Long id);

    /**
     * Check if username already exists
     * @param username the username to check
     * @return true if exists, false otherwise
     */
    boolean existsByUsername(String username);

    /**
     * Check if email already exists
     * @param email the email to check
     * @return true if exists, false otherwise
     */
    boolean existsByEmail(String email);
}
