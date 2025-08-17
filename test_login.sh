#!/bin/bash
# Test login functionality

echo "Testing User Management System Login..."
echo "======================================"

# Base URL
BASE_URL="http://localhost:8080/user-management"

# Test 1: Get login page and extract CSRF token
echo "1. Getting login page..."
CSRF_TOKEN=$(curl -c cookies.txt -s ${BASE_URL}/login | grep -o 'name="_csrf" value="[^"]*"' | cut -d'"' -f4)

if [ -z "$CSRF_TOKEN" ]; then
    echo "❌ Failed to get CSRF token"
    exit 1
fi

echo "✅ CSRF token obtained: ${CSRF_TOKEN:0:20}..."

# Test 2: Attempt login with admin credentials
echo "2. Testing login with admin/password123..."
LOGIN_RESPONSE=$(curl -b cookies.txt -c cookies.txt -s -L -X POST \
  -d "username=admin&password=password123&_csrf=${CSRF_TOKEN}" \
  ${BASE_URL}/authenticateTheUser)

# Check if login was successful by looking for redirect indicators
if [[ $LOGIN_RESPONSE == *"Sign In"* ]]; then
    echo "❌ Login failed - still on login page"
    echo "Response contains: $(echo "$LOGIN_RESPONSE" | grep -o "Invalid username and password" || echo "Unknown error")"
else
    echo "✅ Login successful - redirected from login page"
fi

# Test 3: Try to access protected resource
echo "3. Testing access to protected resource..."
HOME_RESPONSE=$(curl -b cookies.txt -s ${BASE_URL}/home | head -5)

if [[ $HOME_RESPONSE == *"Sign In"* ]]; then
    echo "❌ Not authenticated - redirected to login"
else
    echo "✅ Access to protected resource successful"
    echo "Response preview: $(echo "$HOME_RESPONSE" | head -1)"
fi

# Test 4: Test with wrong credentials
echo "4. Testing with wrong credentials..."
CSRF_TOKEN_2=$(curl -c cookies2.txt -s ${BASE_URL}/login | grep -o 'name="_csrf" value="[^"]*"' | cut -d'"' -f4)
WRONG_LOGIN_RESPONSE=$(curl -b cookies2.txt -c cookies2.txt -s -L -X POST \
  -d "username=admin&password=wrongpassword&_csrf=${CSRF_TOKEN_2}" \
  ${BASE_URL}/authenticateTheUser)

if [[ $WRONG_LOGIN_RESPONSE == *"Invalid username and password"* ]]; then
    echo "✅ Wrong credentials correctly rejected"
else
    echo "❌ Wrong credentials should have been rejected"
fi

# Clean up
rm -f cookies.txt cookies2.txt

echo "======================================"
echo "Login test completed!"
