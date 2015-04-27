# bank-example
An example app in the area of finance. Created as part of a code challenge.

*If you're a participant in the challenge*, please note that, while you're free to use the ideas and methodology from the project, the code is not open-source and can't be used beyond fair use.

# 1 JSON Classes

We've examined the current state of JSON object parsing in the iOS world. There exist some tools that simplify loading the data into the model layer, e.g. Mantle or RESTKit. However, they are in line with the dynamic philosophy of Objective-C and use your model object as part of a schema. 

This approach, while convenient, has significant drawbacks for the cross-platform compatibility: modifying a schema on the backend doesn't automatically do anything for the Objctive-C code; discrepancies will only be caught at the runtime. It would be more useful to implement the information regarding JSON schema in a language-independent way and then generate the code for all supported mobile platforms simultaneously. 

We do that by generating Swift model code from a basic schema-description language. Our python script ([generate.py](https://github.com/ilyannn/bank-example/blob/master/BankExample/BankExample/generate.py)), transforms a simple text file that describes model fields ([Authorization.schema](https://github.com/ilyannn/bank-example/blob/master/BankExample/BankExample/Authorization.schema)) into a generated Swift class ([Authorization.swift](https://github.com/ilyannn/bank-example/blob/master/BankExample/BankExample/Authorization.swift)). That class can be then subclassed into a real model object (similar to how 'mogenerator' works). Note that:

1. Only the simplest possible model is implemented (string/int fields).
2. The generated class supports per-field as well as full-object validation.
3. Only private initializers are generated, thus the class is impossible to access without subclassing in the same file.

Since the generator is run every time the class is compiled, changes in `.schema` file are immediately visible to the developer.


# 2 Key Signing
