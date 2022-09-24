#!/bin/bash
# Robert Taylor
# github.com/webpods/scripts/
# SSL Checker
echo "Usage:"
echo "sslcheck domain.tld server.tld.com"
echo "---------"
echo ""
dom=$1

if [ "$2" == "" ]; then
    server=$1
else
	server=$2
fi

#dom2=www.$1
let CertificateExpirationWarningTrigger=60*60*24
echo "SSL Information for $dom:"
echo " --------------------------- "
echo|openssl s_client -servername $dom -connect $server:443 2>/dev/null|openssl x509 -noout -issuer -subject -ext subjectAltName -dates -fingerprint -serial
echo " --------------------------- "
echo "CLI: echo|openssl s_client -servername $dom -connect $server:443 2>/dev/null|openssl x509 -noout -issuer -subject -ext subjectAltName -dates -fingerprint -serial"
echo " "
#echo "Checking with" `openssl version|awk {'print $1,$2'};`

