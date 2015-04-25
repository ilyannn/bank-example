#!/bin/sh

#  gen.sh
#  BankExample
#
#  Created by Ilya Nikokoshev on 25/04/15.
#  Copyright (c) 2015 ilya n. All rights reserved.

ssh-keygen -t rsa -b 1024 -f key
openssl pkcs12 -export -nocerts -inkey key -out key.p12
