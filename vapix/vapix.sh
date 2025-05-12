#!/bin/bash

# factory defaults
DEFAULT_USER="swae"
DEFAULT_PASS="5Giotlead"
DEFAULT_IP="192.168.1.57"
DEFAULT_HTTP_METHOD="POST"


echo "Choose one auth type: "
echo "1) Basic"
echo "2) Digest"
echo "3) JWT"
read -p "(1/2/3) > " auth_choice

case "$auth_choice" in
    1)
        auth_method="basic"
        ;;
    2)
        auth_method="digest"
        ;;
    3)
        auth_method="jwt (not full support yet)"
        ;;

    *):
        echo "Invalid! Please enter 1, 2 or 3"
        exit 1
        ;;
esac

read -p "Username: [$DEFAULT_USER]: " -r username
username="${username:-$DEFAULT_USER}"

read -s -p "Password: (Default is filled in)" -r password
password="${password:-$DEFAULT_PASS}"
echo

read -p "HTTP Method? [$DEFAULT_HTTP_METHOD]: " -r http_method
http_method="${http_method:-$DEFAULT_HTTP_METHOD}"

read -p "Target IP address? [$DEFAULT_IP]: " -r ip_addr
ip_addr="${ip_addr:-$DEFAULT_IP}"

read -e -p "A json file path for JSON input parameters: " json_path

# curl command
if [[ "$auth_method" == "jwt" ]]; then
    read -p "JWT tok?n: " jwt_token
    curl_cmd="curl -X $http_method -H \"Authorization: Bearer $jwt_token\" -H \"Content-Type: application/json\" -d @$json_path http://$ip_addr/axis-cgi/customhttpheader.cgi | jq ."
else
    curl_cmd="curl -u $username:$password --$auth_method -X $http_method -H \"Content-Type: application/json\" -d @$json_path http://$ip_addr/axis-cgi/customhttpheader.cgi | jq ."
fi

echo "Issue HTTP Request:"
echo "$curl_cmd"
eval $curl_cmd

