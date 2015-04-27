# bank-example
An example app in the area of finance. Created as part of a code challenge.

*If you're a participant in the challenge*, please note that, while you're free to use the ideas and methodology from the project, the code is not open-source and can't be used beyond fair use.

# 1 Exploring the code

The main logic is implemented in the following classes (note how Swift is more readable compared to Objective-C):

* [login view controller](https://github.com/ilyannn/bank-example/blob/master/BankExample/BankExample/Login%20View%20Controller.swift) only has the UI logic
* [authorization](https://github.com/ilyannn/bank-example/blob/master/BankExample/BankExample/Authorization%20Operation.swift) is implemented as an `NSOperation` subclass
* [network access](https://github.com/ilyannn/bank-example/blob/master/BankExample/BankExample/Network.swift) is implemented as a separate, easy-to-test object (more on that below)


# 2 JSON Classes

We've examined the current state of JSON object parsing in the iOS world. There exist some tools that simplify loading the data into the model layer, e.g. Mantle or RESTKit. However, they work along the lines of the dynamic philosophy of Objective-C and use your model object as part of a schema. 

This approach, while convenient, has significant drawbacks for the cross-platform development: modifying a schema on the backend doesn't automatically do anything for the Objective-C code; discrepancies will only be caught at the runtime. It would be more useful to implement the information regarding JSON schema in a language-independent way and then generate the code for all supported mobile platforms simultaneously. 

We do that by generating Swift model code from a basic schema-description language. Our basic Python script ([generate.py](https://github.com/ilyannn/bank-example/blob/master/BankExample/BankExample/generate.py)), transforms a simple text file that describes model fields ([Authorization.schema](https://github.com/ilyannn/bank-example/blob/master/BankExample/BankExample/Authorization.schema)) into a generated Swift class ([Authorization.swift](https://github.com/ilyannn/bank-example/blob/master/BankExample/BankExample/Authorization.swift)). That class can be then subclassed into a real model object (similar to how mogenerator works). Note that:

1. Only the simplest possible model is implemented (string/int fields).
2. The generated class supports per-field as well as full-object validation.
3. Only private initializers are generated, thus the class is impossible to access without subclassing in the same file.

Since the generator is run every time the class is compiled, changes in `.schema` file are now immediately visible to the developer.


# 3 Embedding the key

As part of the challenge, we embed an RSA private [key](https://github.com/ilyannn/bank-example/blob/master/TestKeys/key) into the app bundle. This key is generated and then exported in a password-protected form. The password given by the user is then used in the decryption attempt.

To create a new key use [gen.sh](https://github.com/ilyannn/bank-example/blob/master/TestKeys/gen.sh). The first password, used by the keygen, doens't matter; the export password as asked by `openssl` does.

Also note that iOS is picky about the certificate format it accepts, so is seems like the easiest way to go is through a certificate request, which takes 5 `openssl` commands in the script. The good news though is that we open and manipulate the certificate using only the official means: see the wrapper in ([SecureKeys.m](https://github.com/ilyannn/bank-example/blob/master/BankExample/BankExample/SecureKeys.m)).

As a side note, working with  pointers and bridging to C APIs is much easier in Objective-C than is Swift, so we did exactly that. The API we construct, however, is aware of Swift optionality, and thus  uses nullable modifiers in [SecureKeys.h](https://github.com/ilyannn/bank-example/blob/master/BankExample/BankExample/SecureKeys.h).

The password to the key originally supplied is `xxx`.


# 4 Key obfuscation

We've been asked, as part of the challenge, to implement a way to obfuscate the embedded RSA private key, so that an attacker, having knowledge of the obfuscated key, cannot try to decrypt it by brute-forcing the password. This is, unfortunately, incompatible with the goal of starting from the key that has already been generated via `ssh-keygen -t rsa -b 1024 -f key`.

The reason is that the data in the RSA private key file, that is stuff between `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----` are far from random. Fundamentally, those data encode some integer numbers, specifically, [prime numbers `p`, `q` and exponents `d`, `e`](https://en.wikipedia.org/wiki/RSA_(cryptosystem)#Key_generation).

Those numbers are very much non-random in the sense that they must satisfy a constraint: `d * e = 1 (mod phi(p * q))`. An attacker that has with a quadruple of numbers that are said to comprise the RSA private key can therefore trivially check whether this claim is consistent with the RSA key definition. Since we weren't able to find an algorithm for mass-generating new RSA private keys from a given RSA private key in such a way that the original key cannot be easily distinguished, we conclude that this task is beyond the scope of the current assignment.

It is possible to implement strong key obfuscation by slightly different means. Suppose we implement the key generation algorithm ourselves. Represent this algorithm as `RSA(seed)` where `seed` are random 1024-bits. Then we can embed `seed ^ hash(password)` into the app bundle; because `seed` was random *now* there is no way to find out which of the possible passwords is correct. Our app will be then signing the message with `RSA(seed ^ hash(user_password)` and each of those keys will be a valid RSA key for each value of `user_password`, thus making a brute-force attack less practical.

# 5 Network service

The code comes with two test network services, mock service (`MockNetworkService` class) and test of the real network service (with the github endpoint, see below). Mock service returns a slighly incorrect date and only accepts `mock` username. Github-based service, of course, returns the date specified in the [now](https://github.com/ilyannn/bank-example/blob/master/TestService/api/now) file.

The services are covered by tests in [NetworkServiceTests.swift](https://github.com/ilyannn/bank-example/blob/master/BankExample/BankExampleTests/NetworkServiceTests.swift).

To change the network service parameter, use the Settings app (the app should reload the settings automatically even without restarting). Empty string (default) means mock service. Note that services are expected to work, so there's no error handling.

# 6 Development methodology

Most [commits](https://github.com/ilyannn/bank-example/commits/master) are tied to the [issues](https://github.com/ilyannn/bank-example/issues?utf8=✓&q=is%3Aissue+).

The code is extensively covered by tests in [BankExampleTests target](https://github.com/ilyannn/bank-example/tree/master/BankExample/BankExampleTests), which are sometimes written before the code itself and sometimes after. 

