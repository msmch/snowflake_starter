#!/bin/bash

KEY_NAME=$1

if [ -z "$KEY_NAME" ]; then
  echo "Usage: $0 <key_name>"
  exit 1
fi

openssl genrsa 2048 | openssl pkcs8 -topk8 -nocrypt -out "${KEY_NAME}_private_key.p8"
openssl rsa -in "${KEY_NAME}_private_key.p8" -pubout -out "${KEY_NAME}_public_key.pub"