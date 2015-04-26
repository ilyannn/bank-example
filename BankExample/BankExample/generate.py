import sys
import re
from string import Template

def process(obj): 
    print "Processing", obj
    schemap = obj + ".schema"
    swiftp = obj + ".swift"

    with open(schemap, 'r') as schemaf:
        description = schemaf.read()
    
    schema = load_schema(description)
    print schema
        
    with open(swiftp, 'r') as swiftf:
        swift = swiftf.read()

    generated = generate(obj, schema)

    with open(swiftp, 'w') as swiftf:
        swiftf.write(replace_generated(generated, swift))
        print "File updated: ", swiftp


TEMPLATE = Template("""
class ${obj}_Generated: Generated { 
    
    // Object schema
    
    override var keys_generated: [String] {
        return [${keys}]        
    }
    
    
    // Generated properties
    ${generated}
    
    
    // Validation (Objective-C wrappers)
    ${validate_objc}

    
    // Validation (native Swift)
    ${validate_swift}
}
""")

BEGIN_GENERATE = "// BEGIN GENERATED CODE: DO NOT EDIT MANUALLY" 
END_GENERATE = "// END GENERATED CODE"


def upFirst(something):
    return something[:1].upper() + something[1:]

def property_generate(args):
    key, type = args
    initial = '""' if type == "string" else '0'
    return """
    private(set) var {} = {}""".format(key, initial)


def validate_objc_generate(args):
    key, type = args
    nstype = "NSString" if type == "string" else "NSNumber"
    fix = " as String" if type == "string" else ".integerValue"
    
    return Template("""
    func validate${Key}(value: ObjectPointer, error: NSErrorPointer) -> Bool {
        return validate(value) { ($key: ${NSType}) in
            validate($key: ${key}${fix})
        }
    }
""").substitute(key = key, Key = upFirst(key), NSType = nstype, fix = fix)


def validate_swift_generate(args):
    key, type = args
    initial = '""' if type == "string" else '0'
    return Template("""
    func validate(#${key}: ${Type}) -> ValidationError? {
        return nil
    }
""").substitute(key = key, Type = upFirst(type))


def generate(obj, schema):
    keys = map(lambda x: '"{}"'.format(x), schema.keys())
    generated = map(property_generate, schema.items())
    validate_objc = map(validate_objc_generate, schema.items())
    validate_swift = map(validate_swift_generate, schema.items())
    
    return TEMPLATE.substitute(
        obj = obj, 
        keys = ', '.join(keys),
        generated = ''.join(generated), 
        validate_objc = ''.join(validate_objc),
        validate_swift = ''.join(validate_swift)
    )


def load_schema(description):
    schema = {}
    for line in description.splitlines():
        matches = re.findall('\w+', line)
        if len(matches) == 2:
            schema[matches[0]] = matches[1]
    return schema


def replace_generated(generated, swift):
    pattern = "(?<={}).*(?={})".format(BEGIN_GENERATE, END_GENERATE)    
    return re.sub(pattern, generated, swift, flags = re.DOTALL)


for obj in sys.argv[1:]:
    process(obj)
