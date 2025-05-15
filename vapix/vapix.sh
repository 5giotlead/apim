#!/bin/bash

# factory defaults
DEFAULT_USER="swae"
DEFAULT_PASS="5Giotlead"
DEFAULT_IP="192.168.1.57"
DEFAULT_HTTP_METHOD="POST"
curl_cmd = ""

echo "Choose one auth type: "
echo "1) Basic"
echo "2) Digest"
read -p "(1/2) > " auth_choice

case "$auth_choice" in
    1)
        auth_method="basic"
        ;;
    2)
        auth_method="digest"
        ;;

    *):
        echo "Invalid! Please enter 1 or 2"
        exit 1
        ;;
esac

echo "Choose one API: "
echo "1) Custom HTTP header API"
echo "2) Applications API (list)"
echo "3) AOA API (control)"
echo "4) Record List API"
echo "5) API List"
echo "6) WhiteList API"
read -p "(input a number) > " api_choice

case "$api_choice" in
    1)
        use_api="/axis-cgi/customhttpheader.cgi"
        use_json="true"
        use_jq="| jq ."
        ;;
    2)
        use_api="/axis-cgi/applications/list.cgi"
        use_json="false"
        use_jq=""
        ;;
    3)
        use_api="/local/objectanalytics/control.cgi"
        use_json="true"
        use_jq="| jq ."
        ;;
    4)
        use_api="/axis-cgi/record/list.cgi?recordingid=all"
        use_json="false"
        use_jq=""
        ;;
    5)
        use_api="/axis-cgi/apidiscovery.cgi"
        use_json="true"
        use_jq="| jq ."
        ;;
    6)
        use_api="/local/Vaxreader/whitelist.cgi?action=get-all"
        use_json="false"
        use_jq=""
        ;;

    *):
        echo "Invalid! Please enter 1 - 6"
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




# curl command
if [[ $use_json = "true" ]]; then
    read -e -p "A json file path for JSON input parameters: " json_path
    curl_cmd="curl -u $username:$password --$auth_method -X $http_method -H \"Content-Type: application/json\" -d @$json_path http://$ip_addr$use_api $use_jq"
else
    curl_cmd="curl -u $username:$password --$auth_method -X $http_method http://$ip_addr$use_api $use_jq"
fi

# curl_cmd = "curl -u $username:$password --$auth_method -X $http_method"
#
# if [[ "$use_json" == "true" ]]; then
#     read -e -p "A json file path for JSON input parameters: " json_path
#     curl_cmd += " -H \"Content-Type: application/json\" -d @$json_path"
# fi
#
# curl_cmd += " http://$ip_addr$use_api $use_jq"

echo "Issue HTTP Request:"
echo "$curl_cmd"
eval $curl_cmd
