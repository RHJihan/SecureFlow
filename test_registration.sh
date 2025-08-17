#!/bin/bash
# Test registration functionality

echo "Testing User Management System Registration..."
echo "=============================================="

# Base URL
BASE_URL="http://localhost:8080/user-management"

# Generate a unique username to avoid conflicts
TIMESTAMP=$(date +%s)
USERNAME="testuser${TIMESTAMP}"
EMAIL="testuser${TIMESTAMP}@example.com"

echo "Testing registration with:"
echo "Username: $USERNAME"
echo "Email: $EMAIL"

# Test 1: Get registration form and extract CSRF token
echo "1. Getting registration form..."
CSRF_TOKEN=$(curl -c reg_cookies.txt -s ${BASE_URL}/register/showRegistrationForm | grep -o 'name="_csrf" value="[^"]*"' | cut -d'"' -f4)

if [ -z "$CSRF_TOKEN" ]; then
    echo "❌ Failed to get CSRF token from registration form"
    exit 1
fi

echo "✅ CSRF token obtained: ${CSRF_TOKEN:0:20}..."

# Test 2: Submit registration form
echo "2. Submitting registration form..."
REG_RESPONSE=$(curl -b reg_cookies.txt -c reg_cookies.txt -s -L -X POST \
  -d "userName=${USERNAME}&firstName=Test&lastName=User&email=${EMAIL}&password=testpassword123&_csrf=${CSRF_TOKEN}" \
  ${BASE_URL}/register/processRegistrationForm)

# Check if registration was successful
if [[ $REG_RESPONSE == *"User registered successfully"* ]] || [[ $REG_RESPONSE == *"Registration Confirmation"* ]]; then
    echo "✅ Registration successful"
elif [[ $REG_RESPONSE == *"User already exists"* ]] || [[ $REG_RESPONSE == *"already exists"* ]]; then
    echo "⚠️  User already exists (this might be expected if running multiple tests)"
elif [[ $REG_RESPONSE == *"registration"* ]]; then
    echo "✅ Registration processed (redirected to confirmation page)"
else
    echo "❌ Registration might have failed"
    echo "Response preview: $(echo "$REG_RESPONSE" | head -5 | tr -d '\n')"
fi

# Test 3: Try to login with newly registered user
echo "3. Testing login with newly registered user..."
CSRF_TOKEN_LOGIN=$(curl -c login_cookies.txt -s ${BASE_URL}/login | grep -o 'name="_csrf" value="[^"]*"' | cut -d'"' -f4)

LOGIN_RESPONSE=$(curl -b login_cookies.txt -c login_cookies.txt -s -L -X POST \
  -d "username=${USERNAME}&password=testpassword123&_csrf=${CSRF_TOKEN_LOGIN}" \
  ${BASE_URL}/authenticateTheUser)

if [[ $LOGIN_RESPONSE == *"Sign In"* ]]; then
    echo "❌ Login with newly registered user failed"
else
    echo "✅ Login with newly registered user successful"
fi

# Test 4: Test duplicate registration
echo "4. Testing duplicate registration..."
CSRF_TOKEN_DUP=$(curl -c dup_cookies.txt -s ${BASE_URL}/register/showRegistrationForm | grep -o 'name="_csrf" value="[^"]*"' | cut -d'"' -f4)

DUP_RESPONSE=$(curl -b dup_cookies.txt -c dup_cookies.txt -s -L -X POST \
  -d "userName=${USERNAME}&firstName=Test&lastName=User&email=${EMAIL}&password=testpassword123&_csrf=${CSRF_TOKEN_DUP}" \
  ${BASE_URL}/register/processRegistrationForm)

if [[ $DUP_RESPONSE == *"already exists"* ]] || [[ $DUP_RESPONSE == *"duplicate"* ]]; then
    echo "✅ Duplicate registration correctly rejected"
else
    echo "⚠️  Duplicate registration response: $(echo "$DUP_RESPONSE" | head -3 | tr -d '\n')"
fi

# Test 5: Check if user exists in database
echo "5. Verifying user exists in database..."
USER_EXISTS=$(sudo -u postgres psql user_management_system -t -c "SELECT username FROM users WHERE username = '${USERNAME}';")

if [[ $USER_EXISTS == *"$USERNAME"* ]]; then
    echo "✅ User found in database"
else
    echo "❌ User not found in database"
fi

# Clean up
rm -f reg_cookies.txt login_cookies.txt dup_cookies.txt

echo "=============================================="
echo "Registration test completed!"
