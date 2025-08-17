package com.jihan.springboot.usermanagement.dao;

import com.jihan.springboot.usermanagement.entity.User;

import java.util.List;

/**
 * Data Access Object interface for User entity
 * 
 * This DAO provides methods to interact with the User table in the database.
 * 
 * @author Jihan
 * @version 1.0.0
 */
public interface UserDao {

    /**
     * Find user by username
     * @param userName the username to search for
     * @return User entity or null if not found
     */
    User findByUserName(String userName);

    /**
     * Find user by email
     * @param email the email to search for
     * @return User entity or null if not found
     */
    User findByEmail(String email);

    /**
     * Find user by ID
     * @param id the user ID
     * @return User entity or null if not found
     */
    User findById(Long id);

    /**
     * Find all users
     * @return list of all users
     */
    List<User> findAll();

    /**
     * Save user
     * @param theUser the user to save
     * @return the saved user
     */
    User save(User theUser);
}
