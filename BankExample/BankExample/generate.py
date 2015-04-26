import sys

def process(obj): 
    print "Processing ", obj
    schemap = obj + ".schema"
    swiftp = obj + ".swift"
    with open(schemap, 'r') as schemaf:
        schema = schemaf.read()
        
    with open(swiftp, 'r') as swiftf:
        swift = remove_generated(swiftf.read())

    with open(swiftp, 'w') as swiftf:
        swiftf.write(add_generated(schema, swift))
        print "File updated at ", swiftp

def remove_generated(swift):
    return swift

def add_generated(schema, swift):
    return swift

for obj in sys.argv[1:]:
    process(obj)
