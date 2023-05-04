#!/bin/bash
# Robert Taylor
# Webpods, LLC
# github.com/webpods/scripts/
# SSL Checker
echo "Usage:"
echo "sslcheck domain.tld server/ip port"
echo "---------"
echo ""
dom=$1

if [ "$2" == "" ]; then
    server=$1
else
	server=$2
fi

if [ "$3" == "" ]; then
    port=443
else
	port=$3
fi

#dom2=www.$1
let CertificateExpirationWarningTrigger=60*60*24
echo "SSL Information for $dom:"
echo " --------------------------- "
echo|openssl s_client -servername $dom -connect $server:$port 2>/dev/null|openssl x509 -noout -issuer -subject -ext subjectAltName -dates -fingerprint -serial
echo " --------------------------- "
echo "CLI: echo|openssl s_client -servername $dom -connect $server:$port 2>/dev/null|openssl x509 -noout -issuer -subject -ext subjectAltName -dates -fingerprint -serial"
echo "--"
if [ "$port" == "443" ]; then
	echo "https://www.sslshopper.com/ssl-checker.html#hostname=https://$dom"
else
	echo "https://www.sslshopper.com/ssl-checker.html#hostname=https://$dom:$port"

fi

