package com.jihan.springboot.usermanagement.dao;

import com.jihan.springboot.usermanagement.entity.User;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.TypedQuery;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Implementation of UserDao interface
 * 
 * This DAO implementation provides data access methods for User entity
 * using JPA EntityManager.
 * 
 * @author Jihan
 * @version 1.0.0
 */
@Repository
public class UserDaoImpl implements UserDao {

	private static final Logger logger = LoggerFactory.getLogger(UserDaoImpl.class);

	private final EntityManager entityManager;

	@Autowired
	public UserDaoImpl(EntityManager theEntityManager) {
		this.entityManager = theEntityManager;
	}

	@Override
	public User findByUserName(String theUserName) {
		logger.debug("Finding user by username: {}", theUserName);
		
		try {
			TypedQuery<User> theQuery = entityManager.createQuery(
				"from User where userName=:uName and enabled=true", User.class);
			theQuery.setParameter("uName", theUserName);
			return theQuery.getSingleResult();
		} catch (NoResultException e) {
			logger.debug("No user found with username: {}", theUserName);
			return null;
		} catch (Exception e) {
			logger.error("Error finding user by username: {}", theUserName, e);
			return null;
		}
	}

	@Override
	public User findByEmail(String email) {
		logger.debug("Finding user by email: {}", email);
		
		try {
			TypedQuery<User> theQuery = entityManager.createQuery(
				"from User where email=:email and enabled=true", User.class);
			theQuery.setParameter("email", email);
			return theQuery.getSingleResult();
		} catch (NoResultException e) {
			logger.debug("No user found with email: {}", email);
			return null;
		} catch (Exception e) {
			logger.error("Error finding user by email: {}", email, e);
			return null;
		}
	}

	@Override
	public User findById(Long id) {
		logger.debug("Finding user by ID: {}", id);
		
		try {
			return entityManager.find(User.class, id);
		} catch (Exception e) {
			logger.error("Error finding user by ID: {}", id, e);
			return null;
		}
	}

	@Override
	public List<User> findAll() {
		logger.debug("Finding all users");
		
		try {
			TypedQuery<User> theQuery = entityManager.createQuery(
				"from User where enabled=true order by userName", User.class);
			return theQuery.getResultList();
		} catch (Exception e) {
			logger.error("Error finding all users", e);
			return List.of();
		}
	}

	@Override
	@Transactional
	public User save(User theUser) {
		logger.debug("Saving user: {}", theUser.getUserName());
		
		try {
			return entityManager.merge(theUser);
		} catch (Exception e) {
			logger.error("Error saving user: {}", theUser.getUserName(), e);
			throw e;
		}
	}
}
