#!/bin/bash

# Configuration
DEFAULT_TB_URL="http://192.168.1.223:8080"
TB_URL="${TB_URL:-$DEFAULT_TB_URL}"
AUTH_ENDPOINT="/api/auth/login"
JWT_FILE="jwt_token.dat"
DEFAULT_USER="bsmi.spx@5giotlead.com"
DEFAULT_PASS="bsmi.spx"

# JWT Management
fetch_jwt() {
	echo "Authenticating with ServicePleX (tb)..."
    auth_payload="{\"username\":\"$username\",\"password\":\"$password\"}"
    
    if ! auth_response=$(curl -sS -X POST \
        -H "Content-Type: application/json" \
        -d "$auth_payload" \
        "$TB_URL$AUTH_ENDPOINT"); then
        echo "ERROR: Connection to auth endpoint failed" >&2
        exit 1
    fi

    if ! token=$(jq -r '.token' <<< "$auth_response"); then
        echo "ERROR: Failed to parse JSON response" >&2
        exit 1
    fi

    if [ -z "$token" ] || [ "$token" == "null" ]; then
        echo "ERROR: Invalid credentials. Server response:" >&2
        echo "$auth_response" >&2
        exit 1
    fi

    echo "$token" > "$JWT_FILE"
    echo "JWT stored in $JWT_FILE"
}

# Main workflow
read -p "Enter username [$DEFAULT_USER]: " -r username
username="${username:-$DEFAULT_USER}"

read -s -p "Enter password [using default]: " -r password
password="${password:-$DEFAULT_PASS}"
echo

# Token handling
if [ -f "$JWT_FILE" ]; then
    read -p "Existing token found. Renew? [y/N]: " -r renew
    if [[ "$renew" =~ ^[Yy]$ ]]; then
        fetch_jwt
    else
        token=$(<"$JWT_FILE")
    fi
else
    fetch_jwt
fi
token=$(<"$JWT_FILE")

# API parameters
read -p "Enter API endpoint: " -r api_endpoint
read -p "HTTP method [GET]: " -r http_method
http_method="${http_method:-GET}"

# Auto-add pagination for device list
if [[ "$api_endpoint" == "/api/tenant/devices" ]]; then
    read -p "Page size [10]: " -r page_size
    page_size="${page_size:-10}"
    read -p "Page number [0]: " -r page_number
    page_number="${page_number:-0}"
    api_endpoint="${api_endpoint}?pageSize=${page_size}&page=${page_number}"
fi

# Data handling
data_option=""
if [[ "$http_method" =~ ^(POST|PUT)$ ]]; then
    read -e -p "Enter JSON file path: " json_path
    [ -n "$json_path" ] && data_option="--data-binary @$json_path"
fi

# Execute request
full_url="${TB_URL}${api_endpoint}"
echo "Calling $http_method $full_url"

curl_cmd="curl -sS -X $http_method \
    -H \"X-Authorization: Bearer $token\" \
    -H \"Content-Type: application/json\" \
    $data_option \"$full_url\""

eval "$curl_cmd" | jq . 2>/dev/null || {
    echo "ERROR: Invalid API response format"
    exit 1
}

exit 0

