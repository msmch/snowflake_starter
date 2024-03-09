#!/bin/bash
openssl genrsa 2048 | openssl pkcs8 -topk8 -nocrypt -out private_key.p8
openssl rsa -in private_key.p8 -pubout -out public_key.pub