package com.jihan.springboot.usermanagement.exception;

/**
 * Exception thrown when attempting to create a user that already exists
 * 
 * @author Jihan
 * @version 1.0.0
 */
public class UserAlreadyExistsException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public UserAlreadyExistsException(String message) {
        super(message);
    }

    public UserAlreadyExistsException(String message, Throwable cause) {
        super(message, cause);
    }
}
