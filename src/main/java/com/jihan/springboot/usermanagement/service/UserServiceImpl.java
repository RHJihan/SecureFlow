package com.jihan.springboot.usermanagement.service;

import com.jihan.springboot.usermanagement.dao.RoleDao;
import com.jihan.springboot.usermanagement.dao.UserDao;
import com.jihan.springboot.usermanagement.dto.UserDto;
import com.jihan.springboot.usermanagement.dto.UserRegistrationDto;
import com.jihan.springboot.usermanagement.entity.Role;
import com.jihan.springboot.usermanagement.entity.User;
import com.jihan.springboot.usermanagement.exception.UserAlreadyExistsException;
import com.jihan.springboot.usermanagement.exception.UserNotFoundException;
import com.jihan.springboot.usermanagement.user.WebUser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Implementation of UserService interface
 * 
 * This service implementation provides user management functionality
 * including registration, authentication, and user operations.
 * 
 * @author Jihan
 * @version 1.0.0
 */
@Service
@Transactional
public class UserServiceImpl implements UserService {

	private static final Logger logger = LoggerFactory.getLogger(UserServiceImpl.class);

	private final UserDao userDao;
	private final RoleDao roleDao;
	private final BCryptPasswordEncoder passwordEncoder;

	@Autowired
	public UserServiceImpl(UserDao userDao, RoleDao roleDao, BCryptPasswordEncoder passwordEncoder) {
		this.userDao = userDao;
		this.roleDao = roleDao;
		this.passwordEncoder = passwordEncoder;
	}

	@Override
	public User findByUserName(String userName) {
		// check the database if the user already exists
		return userDao.findByUserName(userName);
	}

	@Override
	public void save(WebUser webUser) {
		logger.info("Saving user with username: {}", webUser.getUserName());
		
		// Check if user already exists
		if (existsByUsername(webUser.getUserName())) {
			throw new UserAlreadyExistsException("User already exists with username: " + webUser.getUserName());
		}
		
		if (existsByEmail(webUser.getEmail())) {
			throw new UserAlreadyExistsException("User already exists with email: " + webUser.getEmail());
		}
		
		User user = new User();

		// assign user details to the user object
		user.setUserName(webUser.getUserName());
		user.setPassword(passwordEncoder.encode(webUser.getPassword()));
		user.setFirstName(webUser.getFirstName());
		user.setLastName(webUser.getLastName());
		user.setEmail(webUser.getEmail());
		user.setEnabled(true);

		// give user default role of "employee"
		user.setRoles(Arrays.asList(roleDao.findRoleByName("ROLE_EMPLOYEE")));

		// save user in the database
		userDao.save(user);
		logger.info("Successfully saved user: {}", user.getUserName());
	}

	@Override
	public UserDto save(UserRegistrationDto userRegistrationDto) {
		logger.info("Saving user from DTO with username: {}", userRegistrationDto.getUsername());
		
		// Check if user already exists
		if (existsByUsername(userRegistrationDto.getUsername())) {
			throw new UserAlreadyExistsException("User already exists with username: " + userRegistrationDto.getUsername());
		}
		
		if (existsByEmail(userRegistrationDto.getEmail())) {
			throw new UserAlreadyExistsException("User already exists with email: " + userRegistrationDto.getEmail());
		}
		
		User user = new User();
		user.setUserName(userRegistrationDto.getUsername());
		user.setPassword(passwordEncoder.encode(userRegistrationDto.getPassword()));
		user.setFirstName(userRegistrationDto.getFirstName());
		user.setLastName(userRegistrationDto.getLastName());
		user.setEmail(userRegistrationDto.getEmail());
		user.setEnabled(true);

		// give user default role of "employee"
		user.setRoles(Arrays.asList(roleDao.findRoleByName("ROLE_EMPLOYEE")));

		// save user in the database
		User savedUser = userDao.save(user);
		logger.info("Successfully saved user from DTO: {}", savedUser.getUserName());
		
		return convertToDto(savedUser);
	}

	@Override
	@Transactional(readOnly = true)
	public List<UserDto> findAllUsers() {
		logger.debug("Finding all users");
		List<User> users = userDao.findAll();
		return users.stream()
				.map(this::convertToDto)
				.collect(Collectors.toList());
	}

	@Override
	@Transactional(readOnly = true)
	public UserDto findById(Long id) {
		logger.debug("Finding user by ID: {}", id);
		User user = userDao.findById(id);
		if (user == null) {
			throw new UserNotFoundException(id);
		}
		return convertToDto(user);
	}

	@Override
	@Transactional(readOnly = true)
	public boolean existsByUsername(String username) {
		return userDao.findByUserName(username) != null;
	}

	@Override
	@Transactional(readOnly = true)
	public boolean existsByEmail(String email) {
		return userDao.findByEmail(email) != null;
	}

	@Override
	@Transactional(readOnly = true)
	public UserDetails loadUserByUsername(String userName) throws UsernameNotFoundException {
		logger.debug("Loading user by username: {}", userName);
		User user = userDao.findByUserName(userName);

		if (user == null) {
			logger.warn("User not found with username: {}", userName);
			throw new UsernameNotFoundException("Invalid username or password.");
		}

		Collection<SimpleGrantedAuthority> authorities = mapRolesToAuthorities(user.getRoles());
		logger.debug("Successfully loaded user: {} with {} authorities", userName, authorities.size());

		return new org.springframework.security.core.userdetails.User(user.getUserName(), user.getPassword(),
				authorities);
	}

	/**
	 * Convert User entity to UserDto
	 * @param user the user entity
	 * @return user DTO
	 */
	private UserDto convertToDto(User user) {
		Set<String> roleNames = user.getRoles().stream()
				.map(Role::getName)
				.collect(Collectors.toSet());
		
		return new UserDto(
				user.getId(),
				user.getUserName(),
				user.getFirstName(),
				user.getLastName(),
				user.getEmail(),
				user.isEnabled(),
				roleNames
		);
	}

	private Collection<SimpleGrantedAuthority> mapRolesToAuthorities(Collection<Role> roles) {
		Collection<SimpleGrantedAuthority> authorities = new ArrayList<>();

		for (Role tempRole : roles) {
			SimpleGrantedAuthority tempAuthority = new SimpleGrantedAuthority(tempRole.getName());
			authorities.add(tempAuthority);
		}

		return authorities;
	}
}
