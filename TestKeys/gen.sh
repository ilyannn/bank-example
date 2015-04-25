#!/bin/sh

#  gen.sh
#  BankExample
#
#  Created by Ilya Nikokoshev on 25/04/15.
#  Copyright (c) 2015 ilya n. All rights reserved.

# Based on http://stackoverflow.com/a/10038683/115200
ssh-keygen -t rsa -b 1024 -f key
openssl rsa -in key -out rsa-private.key
openssl req -new -key rsa-private.key -out rsa-request.crt
openssl x509 -req -days 3650 -in rsa-request.crt -signkey rsa-private.key -out rsa-cert.crt
openssl x509 -outform der -in rsa-cert.crt -out rsa-cert.der
openssl pkcs12 -export -out key.pfx -inkey rsa-private.key -in rsa-cert.crt