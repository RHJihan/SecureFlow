package com.jihan.springboot.usermanagement.dao;

import com.jihan.springboot.usermanagement.entity.Role;

public interface RoleDao {

	public Role findRoleByName(String theRoleName);
	
}
