# thingy-schema-utils 
A lightweight, zero-dependency utility for precompiling stringifiers and validators for your structured data in JavaScript. Define your Schema in the most simple and non-verbose way and efficiently validate and stringify them.

Supports a wide range of common data types, including strings, numbers, booleans, arrays, objects, and specialized formats like hex strings and emails. + Gives you the power to create new types as well.

# Background
When working on my Service Communication Interface(SCI)-mechanics inspiration to improve on the [thingy-schema-validate](https://www.npmjs.com/package/thingy-schema-validate) hit. 
Despite never running into performance issues, it was obvious that the execution relying on in-time lookups and throwing exceptions had massive improvement potential.

For improving said SCI-mechanics I started to reduce my reliance on throwing exceptions everywhere. Also some nice AI told me that JSON.stringify is relatively slow and that fastify uses [AJV](https://www.npmjs.com/package/ajv) under the hood to compile stringifier functions for SCI responses which significantly improves performance. 

Thus `thingy-schema-utils` was born for gaining same benefits but keeping the nice simple schema definitions from `thingy-schema-validate`.

## Features
- **Nice Schema Definitions**: Write schemas which don't mess up your code.
- **Fast Schema Validation**: Precompile the validator function once from your schema. Validate your data efficiently for the rest of your programs runtime.
- **Fast Stringification**: Precompile the stringifier function once from your schema. Stringify your data efficiently for the rest of your programs runtime. ;-)
- **Extensible**: Define custom types and error messages.
- **Very Performant**: Hurrm, well... We need some benchmarks later^^

# Usage
Installation
------------
```bash
npm install thingy-schema-utils
```

Current Functionality
---------------------
## API Reference

### Exported Constants

- **Basic Types (Enumeration)**: `BOOLEAN`, `NUMBER`, `ARRAY`, `OBJECT`, `STRING`, `STRINGEMAIL`, `STRINGHEX`, `STRINGHEX32`, `STRINGHEX64`, `STRINGHEX128`, `STRINGHEX256`, `STRINGHEX512`, `STRINGCLEAN`, `NONEMPTYSTRING`, `NONEMPTYSTRINGHEX`, `NONEMPTYSTRINGCLEAN`, `NONEMPTYARRAY`, `OBJECTCLEAN`, `NONNULLOBJECT`, `NONNULLOBJECTCLEAN`, `STRINGORNOTHING`, `STRINGEMAILORNOTHING`, `STRINGHEXORNOTHING`, `STRINGHEX32ORNOTHING`, `STRINGHEX64ORNOTHING`, `STRINGHEX128ORNOTHING`, `STRINGHEX256ORNOTHING`, `STRINGHEX512ORNOTHING`, `STRINGCLEANORNOTHING`, `NUMBERORNOTHING`, `BOOLEANORNOTHING`, `ARRAYORNOTHING`, `OBJECTORNOTHING`, `OBJECTCLEANORNOTHING`, `STRINGORNULL`, `STRINGEMAILORNULL`, `STRINGHEXORNULL`, `STRINGHEX32ORNULL`, `STRINGHEX64ORNULL`, `STRINGHEX128ORNULL`, `STRINGHEX256ORNULL`, `STRINGHEX512ORNULL`, `STRINGCLEANORNULL`, `NUMBERORNULL`, `BOOLEANORNULL`, `ARRAYORNULL`
- **Error Codes (Enumeration)**: `NOTANUMBER`, `NOTABOOLEAN`, `NOTANARRAY`, `NOTANOBJECT`, `INVALIDHEX`, `INVALIDEMAIL`, `INVALIDSIZE`, `ISNAN`, `ISNULL`, `ISEMPTYSTRING`, `ISEMPTYARRAY`, `ISDIRTYSTRING`, `ISDIRTYOBJECT`, `ISNOTFINITE`, `ISINVALID`

### Functions

- `createValidator(schema, staticStrings)`: Returns a validator function.
- `createStringifier(schema)`: Returns a stringifier function.
- `getErrorMessage(errorCode)`: Returns the error message for a given code.
- `defineNewType(validatorFunc, stringifyFunc)`: Adds a new type.
- `defineNewError(errorMessage)`: Adds a new error code.
- `setTypeFunctions(type, validatorFunc, stringifyFunc)`: Overrides typeValidator and typeStringifier for given type.
- `lock()`: Freezes internal maps.

### 1. Basic Validation

Before Validation you may create your own custom types and error messages and lock the module to deny any mutation.

You may create nice multilevel schemas of arbitrary depth. Then compile the validator for fast validation.

When the object passed to the validator is valid the function simply returns void/`undefined` -> falsly value is valid. 
For invalod objects the `errorCode` is returned which is a number.
You get the corresponding errorMessage with `getErrorMessage`

```javascript
import {
  STRINGCLEAN, NUMBER, BOOLEAN, ARRAY, createValidator, createStringifier,
  getErrorMessage
} from 'thingy-schema-utils';

// Define your schema
const userSchema = {
  name: STRINGCLEAN,
  age: NUMBER,
  isAdmin: BOOLEAN,
  tags: ARRAY,
  address: {
    street: STRINGCLEAN,
    city: STRINGCLEAN,
    country: STRINGCLEAN
  }
};

// Create a validator
const validate = createValidator(userSchema);

// Validate data
const userData = {
  name: "Alice",
  age: 30,
  isAdmin: true,
  tags: ["user", "admin"],
  address: { city: "Berlin", street: "Meinestrasse 666", country:"Deutschland" }
};

const error = validate(userData);
if (error) {
  console.error("Validation failed: ", getErrorMessage(error));
} else {
  console.log("Data is valid!");
}
```

### 2. Stringification

Be sure that your object is valid. The stringifer does not validate the argument and might throw an exception if any unexpected issue occurs. The stringifier expects a valid data structure :-).

```javascript
const stringifyUser = createStringifier(userSchema);
const userString = stringifyUser(userData);
console.log(userString);
// Output: '{"name":"Alice","age":30,"isAdmin":true,"tags":["user","admin"],"address":{"city":"Berlin","street":"Meinestrasse 666","country":"Deutschland"}}'
```

### 3. Special Cases

In some situations you want to have a 0 level schema. This is perfectly legal! :D

```javascript
const hashSchema = STRINGHEX32
const validateHash = createValidator(hashSchema);
const error = validateHash("a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4");
```

Also maybe you want to bake a static string into your schema.
For this you must pass true for the `staticStrings` argument.

```javascript
const userSchema = {
    role: "user",
    name: STRINGCLEAN
}
const validateUser = createValidator(userSchema, true);
const error = validateUser({role:"user", name: "Max Mustermann"});
```

### 4. Custom Types and Errors
You have all the power to add your specific types or to overwrite the validators and stringifiers of any already given type as long as they are not `locked`.

Notice that there has been an arbitrary limit of a maximum of 999 different types and 999 different errorCodes. This limit is very arbitrarily set to a number which is thought to never be reached.

```javascript
// Define a new error
const NO = defineNewError("Simply NO!");

// Define a new type
const STRINGSIZED = defineNewType(
  (a) => { if(typeof a != "string" || a.length > 10 || a.length < 3) return NO },
  (a) => { return '"'+a+'"' }
);
```

### 5. Locking the Library
For a certain safety-net you may lock the library to prevent overwriting your configuration later.

If you donot change any types you may simply call `lock()` immediately and start to compile your validators and stringifiers.

```javascript
lock(); // Prevents further mutations to types and errors
```

---

## Default Types

`thingy-schema-utils` provides a wide range of built-in types for common validation and stringification needs.
Here’s an extensive list of all available types:

---
### Core Types
- `STRING`: JS type `"string"`. (including `""`, `"\x00"`)
- `NUMBER`: JS type `"number"`. (excluding `NaN`, `Infinity`, `-Infinity` )
- `BOOLEAN`: JS type `"boolean"`
- `ARRAY`: Legit JS Array. (including `[]`, excluding `null`)
- `OBJECT`: JS type `"object"`. (including `null`,`{}`)

### Special String Types - valid `STRING` +
- `STRINGEMAIL`: Email address Format. Mostly RFC5322 BUT: ASCII only without `'"'`, `"!"`, `" "`, `"#"`, `"$"`, `"%"`, `"&"`, `"'"`, `"*"`, `"/"`, `"="`, `"?"`, `"^"`, `"{"`, `"|"`, `"}"`, `"~"` and "`" in front of the @ plus comments and quoted strings are illegal.
- `STRINGHEX`: All hexadecimal characters.
- `STRINGHEX32`: 32 hexadecimal characters.
- `STRINGHEX64`: 64 hexadecimal characters.
- `STRINGHEX128`: 128 hexadecimal characters.
- `STRINGHEX256`: 256 hexadecimal characters.
- `STRINGHEX512`: 512 hexadecimal characters.

### Cleaner Types
- `STRINGCLEAN`: `STRING` but excluding control characters or invisible whitespace characters.
- `NONEMPTYSTRING`: `STRING` but excluding `""`.
- `NONEMPTYSTRINGHEX`: `STRINGHEX` but excluding `""`
- `NONEMPTYSTRINGCLEAN`: `STRINGCLEAN` but excluding `""`
- `NONEMPTYARRAY`: `ARRAY` but excluding `[]`
- `OBJECTCLEAN`: `OBJECT` without properties like `"__proto__"`, `"constructor"` and `"prototype"`
- `NONNULLOBJECT`: `OBJECT` but excluding `null`
- `NONNULLOBJECTCLEAN`: `OBJECTCLEAN` but excluding `null`

### Optional Types
They might be nonexistant  or `undefined` in the object to-be-validated.
- `STRINGORNOTHING`
- `STRINGEMAILORNOTHING`
- `STRINGHEXORNOTHING`
- `STRINGHEX32ORNOTHING`
- `STRINGHEX64ORNOTHING`
- `STRINGHEX128ORNOTHING`
- `STRINGHEX256ORNOTHING`
- `STRINGHEX512ORNOTHING`
- `STRINGCLEANORNOTHING`
- `NUMBERORNOTHING`
- `BOOLEANORNOTHING`
- `ARRAYORNOTHING`
- `OBJECTORNOTHING`
- `OBJECTCLEANORNOTHING`

### Types that may explicitly be `null`
They must exist but may be `null`
- `STRINGORNULL`
- `STRINGEMAILORNULL`
- `STRINGHEXORNULL`
- `STRINGHEX32ORNULL`
- `STRINGHEX64ORNULL`
- `STRINGHEX128ORNULL`
- `STRINGHEX256ORNULL`
- `STRINGHEX512ORNULL`
- `STRINGCLEANORNULL`
- `NUMBERORNULL`
- `BOOLEANORNULL`
- `ARRAYORNULL`

## Default ErrorCodes
Remember that the definitions are enumerated so you might import `NOTANUMBER` and check against this specific errorCode for further decisions. But for simple human readable output the function `getErrorMessage(errorCode)` is the way to go.
- `NOTASTRING` => "Not a String!"
- `NOTANUMBER` => "Not a Number!"
- `NOTABOOLEAN` => "Not a Boolean!"
- `NOTANARRAY` => "Not an Array!"
- `NOTANOBJECT` => "Not an Object!"
- `INVALIDHEX` => "String is not valid hex!"
- `INVALIDEMAIL` => "String is not a valid email!"
- `INVALIDSIZE` => "String size mismatch!"
- `ISNAN` => "Number is NaN!"
- `ISNULL` => "Object is null!"
- `ISEMPTYSTRING` => "String is empty!"
- `ISEMPTYARRAY` => "Array is empty!"
- `ISDIRTYSTRING` => "String is dirty!"
- `ISDIRTYOBJECT` => "Object is dirty!"
- `ISNOTFINITE` => "Number is not finite!"
- `ISINVALID` => "Schema is invalid!"


# Further steps

- Fix bugs
- Intruduce new types that seem useful


All sorts of inputs are welcome, thanks!

---

# License
[CC0](https://creativecommons.org/publicdomain/zero/1.0/)
