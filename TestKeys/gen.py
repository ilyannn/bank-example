from Crypto.PublicKey import RSA

with open('key', 'rb') as f:
    private = RSA.importKey(f.read())
    print private
