#!/bin/bash
# Test authorization functionality

echo "Testing User Management System Authorization..."
echo "=============================================="

BASE_URL="http://localhost:8080/user-management"

# Function to test login and access
test_user_access() {
    local username=$1
    local password=$2
    local expected_role=$3
    
    echo "Testing access for user: $username (expected role: $expected_role)"
    
    # Get CSRF token and login
    CSRF_TOKEN=$(curl -c "cookies_${username}.txt" -s ${BASE_URL}/login | grep -o 'name="_csrf" value="[^"]*"' | cut -d'"' -f4)
    
    LOGIN_RESPONSE=$(curl -b "cookies_${username}.txt" -c "cookies_${username}.txt" -s -L -X POST \
      -d "username=${username}&password=${password}&_csrf=${CSRF_TOKEN}" \
      ${BASE_URL}/authenticateTheUser)
    
    if [[ $LOGIN_RESPONSE == *"Sign In"* ]]; then
        echo "❌ Login failed for $username"
        return 1
    fi
    
    # Test access to different endpoints
    echo "  Testing access to /home (EMPLOYEE required)..."
    HOME_RESPONSE=$(curl -b "cookies_${username}.txt" -s -w "%{http_code}" ${BASE_URL}/home)
    if [[ $HOME_RESPONSE == *"200"* ]]; then
        echo "  ✅ Access to /home allowed"
    else
        echo "  ❌ Access to /home denied"
    fi
    
    echo "  Testing access to /leaders (MANAGER required)..."
    LEADERS_RESPONSE=$(curl -b "cookies_${username}.txt" -s -w "%{http_code}" ${BASE_URL}/leaders)
    if [[ $LEADERS_RESPONSE == *"200"* ]]; then
        echo "  ✅ Access to /leaders allowed"
    elif [[ $LEADERS_RESPONSE == *"403"* ]]; then
        echo "  ⚠️  Access to /leaders denied (expected for non-managers)"
    else
        echo "  ❌ Unexpected response for /leaders: $LEADERS_RESPONSE"
    fi
    
    echo "  Testing access to /systems (ADMIN required)..."
    SYSTEMS_RESPONSE=$(curl -b "cookies_${username}.txt" -s -w "%{http_code}" ${BASE_URL}/systems)
    if [[ $SYSTEMS_RESPONSE == *"200"* ]]; then
        echo "  ✅ Access to /systems allowed"
    elif [[ $SYSTEMS_RESPONSE == *"403"* ]]; then
        echo "  ⚠️  Access to /systems denied (expected for non-admins)"
    else
        echo "  ❌ Unexpected response for /systems: $SYSTEMS_RESPONSE"
    fi
    
    # Clean up cookies
    rm -f "cookies_${username}.txt"
    echo ""
}

# Test different users
echo "1. Testing admin user (should have access to all resources)..."
test_user_access "admin" "password123" "ADMIN"

echo "2. Testing manager user (should have access to home and leaders)..."
test_user_access "manager" "password123" "MANAGER"

echo "3. Testing employee user (should have access to home only)..."
test_user_access "employee" "password123" "EMPLOYEE"

echo "=============================================="
echo "Authorization test completed!"
