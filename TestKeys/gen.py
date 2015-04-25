# Assuming you ran: ssh-keygen -t rsa -b 1024 -f key 

from Crypto.PublicKey import RSA

with open('key', 'rb') as f:
    private = RSA.importKey(f.read())
    print private
