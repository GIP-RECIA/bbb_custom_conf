#!/bin/bash

HOST=$1
SECRET=$2

time=$(date +%s)
expiry=8400
username=$(( $time + $expiry ))

echo
echo "          https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/"
echo
echo      URI : turn:$HOST:443
echo username : $username 
echo password : $(echo -n $username | openssl dgst -binary -sha1 -hmac $SECRET | openssl base64)
echo


