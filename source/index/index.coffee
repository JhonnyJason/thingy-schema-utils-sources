############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("schemamodule")
#endregion

############################################################
## Notice: NUMBER validation
# Due to JSON limitations NaN and (-)Infinity are invalid
# This means that NUMBER type already excludes these values
# Previously we had FINITENUMBER and NONANNUMBER 
# These types are gone now :-)

############################################################
#region Schema Types and Functions
export STRING = 1
export STRINGEMAIL = 2 
export STRINGHEX = 3
export STRINGHEX32 = 4
export STRINGHEX64 = 5
export STRINGHEX128 = 6
export STRINGHEX256 = 7
export STRINGHEX512 = 8
export NUMBER = 9
export BOOLEAN = 10
export ARRAY = 11
export OBJECT = 12

export STRINGORNOTHING = 13
export STRINGEMAILORNOTHING = 14
export STRINGHEXORNOTHING = 15
export STRINGHEX32ORNOTHING = 16
export STRINGHEX64ORNOTHING = 17
export STRINGHEX128ORNOTHING = 18
export STRINGHEX256ORNOTHING = 19
export STRINGHEX512ORNOTHING = 20
export NUMBERORNOTHING = 21
export BOOLEANORNOTHING = 22
export ARRAYORNOTHING = 23
export OBJECTORNOTHING = 24

export STRINGORNULL = 25
export STRINGEMAILORNULL = 26
export STRINGHEXORNULL = 27
export STRINGHEX32ORNULL = 28
export STRINGHEX64ORNULL = 29
export STRINGHEX128ORNULL = 30
export STRINGHEX256ORNULL = 31
export STRINGHEX512ORNULL = 32
export NUMBERORNULL = 33
export BOOLEANORNULL = 34
export ARRAYORNULL = 35

export NONNULLOBJECT = 36
export NONEMPTYSTRING = 37
export NONEMPTYARRAY = 38
export NONEMPTYSTRINGHEX = 39
export NONEMPTYSTRINGCLEAN = 40
export STRINGCLEAN = 41
export STRINGCLEANORNULL = 42 
export STRINGCLEANORNOTHING = 43
export OBJECTCLEAN = 44
export NONNULLOBJECTCLEAN = 45
export OBJECTCLEANORNOTHING = 46

############################################################
typeValidationFunctions = new Array(47)
typeStringifyFunctions = new Array(47)

############################################################
#region basic typeValidationFunctions definitions
typeValidationFunctions[STRING] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    return

typeValidationFunctions[STRINGEMAIL] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    if arg.length > 320 or arg.length < 5 then return INVALIDSIZE
    if invalidEmailSmallRegex.test(arg) then return INVALIDEMAIL
    # if arg.indexOf("..") >= 0 then return INVALIDEMAIL
    # if arg.indexOf("--") >= 0 then return INVALIDEMAIL
    # if arg.indexOf("-.") >= 0 then return INVALIDEMAIL
    # if arg.indexOf(".-") >= 0 then return INVALIDEMAIL

    atPos = arg.indexOf("@")
    
    if atPos <= 0 or atPos > 64 or (arg.length - atPos) < 4 or 
    arg[0] == "." or arg[atPos - 1] == "." or arg[0] == "-" or 
    arg[atPos - 1] == "-" or arg[atPos + 1] == "." or 
    arg[atPos + 1] == "-" 
        return INVALIDEMAIL
    
    # if atPos <= 0 then return INVALIDEMAIL
    # if atPos > 64 then return INVALIDEMAIL
    # if arg[0] == "." or arg[atPos - 1] == "." then return INVALIDEMAIL
    # if arg[0] == "-" or arg[atPos - 1] == "-" then return INVALIDEMAIL
    # if arg[atPos + 1] == "." or arg[atPos + 1] == "-" then return INVALIDEMAIL
    
    for c,i in arg
        if !(domainCharMap[c] or i == atPos or
            (i < atPos and (c == "+" or c == "_"))
            ) then return INVALIDEMAIL
    
    if arg[arg.length - 1] == "." or arg[arg.length - 1] == "-"
        return INVALIDEMAIL 

    lastPos = atPos
    dotPos = arg.indexOf(".", atPos + 1)
    if dotPos < 0 then return INVALIDEMAIL
    
    while (dotPos > 0)
        if (dotPos - lastPos) > 63 then return INVALIDEMAIL
        lastPos = dotPos
        dotPos = arg.indexOf(".", lastPos + 1)
    
    tld = arg.slice(lastPos + 1)
    if numericOnlyRegex.test(tld) then return INVALIDEMAIL
    return

typeValidationFunctions[STRINGHEX] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX32] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 32 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX64] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 64 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX128] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 128 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX256] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 256 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX512] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 512 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[NUMBER] = (arg) ->
    if typeof arg != "number" then return NOTANUMBER
    if arg == NaN then return ISNAN 
    if arg == Infinity or arg == -Infinity then return ISNOTFINITE
    return

typeValidationFunctions[BOOLEAN] = (arg) ->
    if typeof arg != "boolean" then return NOTABOOLEAN
    return

typeValidationFunctions[ARRAY] = (arg) ->
    if !Array.isArray(arg) then return NOTANARRAY
    return

typeValidationFunctions[OBJECT] = (arg) ->
    if typeof arg != "object" then return NOTANOBJECT
    return

typeValidationFunctions[STRINGORNOTHING] = (arg) ->
    return if arg == undefined 
    if typeof arg != "string" then return NOTASTRING
    return

typeValidationFunctions[STRINGEMAILORNOTHING] = (arg) ->
    return if arg == undefined 
    if typeof arg != "string" then return NOTASTRING
    
    if arg.length > 320 or arg.length < 5 then return INVALIDSIZE
    if invalidEmailSmallRegex.test(arg) then return INVALIDEMAIL
    # if arg.indexOf("..") >= 0 then return INVALIDEMAIL
    # if arg.indexOf("--") >= 0 then return INVALIDEMAIL
    # if arg.indexOf("-.") >= 0 then return INVALIDEMAIL
    # if arg.indexOf(".-") >= 0 then return INVALIDEMAIL

    atPos = arg.indexOf("@")
    
    if atPos <= 0 or atPos > 64 or (arg.length - atPos) < 4 or 
    arg[0] == "." or arg[atPos - 1] == "." or arg[0] == "-" or 
    arg[atPos - 1] == "-" or arg[atPos + 1] == "." or 
    arg[atPos + 1] == "-" 
        return INVALIDEMAIL
    
    # if atPos <= 0 then return INVALIDEMAIL
    # if atPos > 64 then return INVALIDEMAIL
    # if arg[0] == "." or arg[atPos - 1] == "." then return INVALIDEMAIL
    # if arg[0] == "-" or arg[atPos - 1] == "-" then return INVALIDEMAIL
    # if arg[atPos + 1] == "." or arg[atPos + 1] == "-" then return INVALIDEMAIL
    
    for c,i in arg 
        if !(domainCharMap[c] or i == atPos or
            (i < atPos and (c == "+" or c == "_"))
            ) then return INVALIDEMAIL
    
    if arg[arg.length - 1] == "." or arg[arg.length - 1] == "-"
        return INVALIDEMAIL 

    lastPos = atPos
    dotPos = arg.indexOf(".", atPos + 1)
    if dotPos < 0 then return INVALIDEMAIL
    
    while (dotPos > 0)
        if (dotPos - lastPos) > 63 then return INVALIDEMAIL
        lastPos = dotPos
        dotPos = arg.indexOf(".", lastPos + 1)
    
    tld = arg.slice(lastPos + 1)
    if numericOnlyRegex.test(tld) then return INVALIDEMAIL
    return

typeValidationFunctions[STRINGHEXORNOTHING] = (arg) ->
    return if arg == undefined
    if typeof arg != "string" then return NOTASTRING
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX32ORNOTHING] = (arg) ->
    return if arg == undefined
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 32 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX64ORNOTHING] = (arg) ->
    return if arg == undefined
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 64 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX128ORNOTHING] = (arg) ->
    return if arg == undefined
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 128 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX256ORNOTHING] = (arg) ->
    return if arg == undefined 
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 256 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX512ORNOTHING] = (arg) ->
    return if arg == undefined 
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 512 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[NUMBERORNOTHING] = (arg) ->
    return if arg == undefined 
    if typeof arg != "number" then return NOTANUMBER
    if arg == NaN then return ISNAN 
    if arg == Infinity or arg == -Infinity then return ISNOTFINITE
    return

typeValidationFunctions[BOOLEANORNOTHING] = (arg) ->
    return if arg == undefined 
    if typeof arg != "boolean" then return NOTABOOLEAN
    return

typeValidationFunctions[ARRAYORNOTHING] = (arg) ->
    return if arg == undefined 
    if !Array.isArray(arg) then return NOTANARRAY
    return

typeValidationFunctions[OBJECTORNOTHING] = (arg) ->
    return if arg == undefined
    if typeof arg != "object" then return NOTANOBJECT
    return

typeValidationFunctions[STRINGORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "string" then return NOTASTRING
    return

typeValidationFunctions[STRINGEMAILORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "string" then return NOTASTRING
    if arg.length > 320 or arg.length < 5 then return INVALIDSIZE
    if invalidEmailSmallRegex.test(arg) then return INVALIDEMAIL
    # if arg.indexOf("..") >= 0 then return INVALIDEMAIL
    # if arg.indexOf("--") >= 0 then return INVALIDEMAIL
    # if arg.indexOf("-.") >= 0 then return INVALIDEMAIL
    # if arg.indexOf(".-") >= 0 then return INVALIDEMAIL

    atPos = arg.indexOf("@")
    
    if atPos <= 0 or atPos > 64 or (arg.length - atPos) < 4 or
    arg[0] == "." or arg[atPos - 1] == "." or arg[0] == "-" or 
    arg[atPos - 1] == "-" or arg[atPos + 1] == "." or 
    arg[atPos + 1] == "-"
        return INVALIDEMAIL
    
    # if atPos <= 0 then return INVALIDEMAIL
    # if atPos > 64 then return INVALIDEMAIL
    # if arg[0] == "." or arg[atPos - 1] == "." then return INVALIDEMAIL
    # if arg[0] == "-" or arg[atPos - 1] == "-" then return INVALIDEMAIL
    # if arg[atPos + 1] == "." or arg[atPos + 1] == "-" then return INVALIDEMAIL
    
    for c,i in arg 
        if !(domainCharMap[c] or i == atPos or
            (i < atPos and (c == "+" or c == "_"))
            ) then return INVALIDEMAIL
    
    if arg[arg.length - 1] == "." or arg[arg.length - 1] == "-"
        return INVALIDEMAIL 

    lastPos = atPos
    dotPos = arg.indexOf(".", atPos + 1)
    if dotPos < 0 then return INVALIDEMAIL
    
    while (dotPos > 0)
        if (dotPos - lastPos) > 63 then return INVALIDEMAIL
        lastPos = dotPos
        dotPos = arg.indexOf(".", lastPos + 1)
    
    tld = arg.slice(lastPos + 1)
    if numericOnlyRegex.test(tld) then return INVALIDEMAIL
    return

typeValidationFunctions[STRINGHEXORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "string" then return NOTASTRING
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX32ORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 32 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX64ORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 64 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX128ORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 128 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX256ORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 256 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX512ORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 512 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[NUMBERORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "number" then return NOTANUMBER
    if arg == NaN then return ISNAN 
    if arg == Infinity or arg == -Infinity then return ISNOTFINITE
    return

typeValidationFunctions[BOOLEANORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "boolean" then return NOTABOOLEAN
    return

typeValidationFunctions[ARRAYORNULL] = (arg) ->
    return if arg == null
    if !Array.isArray(arg) then return NOTANARRAY
    return

typeValidationFunctions[NONNULLOBJECT] = (arg) ->
    if typeof arg != "object" then return NOTANOBJECT
    if arg == null then return ISNULL
    return

typeValidationFunctions[NONEMPTYSTRING] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    if arg.length == 0 then return ISEMPTYSTRING
    return

typeValidationFunctions[NONEMPTYARRAY] = (arg) ->
    if !Array.isArray(arg) then return NOTANARRAY
    if arg.length == 0 then return ISEMPTYARRAY
    return

typeValidationFunctions[NONEMPTYSTRINGHEX] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    if arg.length == 0 then return ISEMPTYSTRING
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[NONEMPTYSTRINGCLEAN] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    if arg.length == 0 then return ISEMPTYSTRING
    for c in arg when dirtyCharMap[c] then return ISDIRTYSTRING
    return

typeValidationFunctions[STRINGCLEAN] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    for c in arg when dirtyCharMap[c] then return ISDIRTYSTRING
    return

typeValidationFunctions[STRINGCLEANORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "string" then return NOTASTRING
    for c in arg when dirtyCharMap[c] then return ISDIRTYSTRING
    return

typeValidationFunctions[STRINGCLEANORNOTHING] = (arg) ->
    return if arg == undefined
    if typeof arg != "string" then return NOTASTRING
    for c in arg when dirtyCharMap[c] then return ISDIRTYSTRING
    return

typeValidationFunctions[OBJECTCLEAN] = (arg) ->
    if typeof arg != "object" then return NOTANOBJECT
    if isDirtyObject(arg) then return ISDIRTYOBJECT
    return

typeValidationFunctions[NONNULLOBJECTCLEAN] = (arg) ->
    if typeof arg != "object" then return NOTANOBJECT
    if arg == null then return ISNULL
    if isDirtyObject(arg) then return ISDIRTYOBJECT
    return

typeValidationFunctions[OBJECTCLEANORNOTHING] = (arg) ->
    return if arg == undefined
    if typeof arg != "object" then return NOTANOBJECT
    if isDirtyObject(arg) then return ISDIRTYOBJECT
    return

#endregion

############################################################
## raw type stringify 
booleanStringify = (arg) -> 
    if arg  then return 'true' else return 'false'
booleanOrNothingStringify = (arg) ->
    return arg if arg == undefined 
    if arg then return 'true'  else return 'false'
booleanOrNullStringify = (arg) ->
    return 'null' if arg == null
    if arg then return 'true' else return 'false'
numberStringify = (arg) -> ''+arg
numberOrNothingStringify = (arg) -> 
    if arg == undefined then return arg else return ''+arg
numberOrNullStringify = (arg) -> 
    if arg == null then return 'null' else return ''+arg
stringStringify = (arg) -> '"'+arg+'"'
stringOrNothingStringify = (arg) ->
    if arg == undefined then return arg else return '"'+arg+'"'
stringOrNullStringify = (arg) ->
    if arg == null then return 'null' else return '"'+arg+'"'
objectStringify = JSON.stringify
objectOrNothingStringify = (arg) -> 
    if arg == undefined then return arg else return JSON.stringify(arg)

############################################################
#region basic typeStringifyFunction definitions
typeStringifyFunctions[STRING] = stringStringify
typeStringifyFunctions[STRINGEMAIL] = stringStringify
typeStringifyFunctions[STRINGHEX] = stringStringify
typeStringifyFunctions[STRINGHEX32] = stringStringify
typeStringifyFunctions[STRINGHEX64] = stringStringify
typeStringifyFunctions[STRINGHEX128] = stringStringify
typeStringifyFunctions[STRINGHEX256] = stringStringify
typeStringifyFunctions[STRINGHEX512] = stringStringify
typeStringifyFunctions[NUMBER] = numberStringify
typeStringifyFunctions[BOOLEAN] = booleanStringify
typeStringifyFunctions[ARRAY] = objectStringify
typeStringifyFunctions[OBJECT] = objectStringify
typeStringifyFunctions[STRINGORNOTHING] = stringOrNothingStringify
typeStringifyFunctions[STRINGEMAILORNOTHING] = stringOrNothingStringify
typeStringifyFunctions[STRINGHEXORNOTHING] = stringOrNothingStringify
typeStringifyFunctions[STRINGHEX32ORNOTHING] = stringOrNothingStringify
typeStringifyFunctions[STRINGHEX64ORNOTHING] = stringOrNothingStringify
typeStringifyFunctions[STRINGHEX128ORNOTHING] = stringOrNothingStringify
typeStringifyFunctions[STRINGHEX256ORNOTHING] = stringOrNothingStringify
typeStringifyFunctions[STRINGHEX512ORNOTHING] = stringOrNothingStringify
typeStringifyFunctions[NUMBERORNOTHING] = numberOrNothingStringify
typeStringifyFunctions[BOOLEANORNOTHING] = booleanOrNothingStringify
typeStringifyFunctions[ARRAYORNOTHING] = objectOrNothingStringify
typeStringifyFunctions[OBJECTORNOTHING] = objectOrNothingStringify
typeStringifyFunctions[STRINGORNULL] = stringOrNullStringify
typeStringifyFunctions[STRINGEMAILORNULL] = stringOrNullStringify
typeStringifyFunctions[STRINGHEXORNULL] = stringOrNullStringify
typeStringifyFunctions[STRINGHEX32ORNULL] = stringOrNullStringify
typeStringifyFunctions[STRINGHEX64ORNULL] = stringOrNullStringify
typeStringifyFunctions[STRINGHEX128ORNULL] = stringOrNullStringify
typeStringifyFunctions[STRINGHEX256ORNULL] = stringOrNullStringify
typeStringifyFunctions[STRINGHEX512ORNULL] = stringOrNullStringify
typeStringifyFunctions[NUMBERORNULL] = numberOrNullStringify
typeStringifyFunctions[BOOLEANORNULL] = booleanOrNullStringify
typeStringifyFunctions[ARRAYORNULL] = objectStringify
typeStringifyFunctions[NONNULLOBJECT] =  objectStringify 
typeStringifyFunctions[NONEMPTYSTRING] = stringStringify
typeStringifyFunctions[NONEMPTYARRAY] = objectStringify
typeStringifyFunctions[NONEMPTYSTRINGHEX] = stringStringify
typeStringifyFunctions[NONEMPTYSTRINGCLEAN] = stringStringify
typeStringifyFunctions[STRINGCLEAN] = stringStringify
typeStringifyFunctions[STRINGCLEANORNULL] = stringStringify
typeStringifyFunctions[STRINGCLEANORNOTHING] = stringStringify
typeStringifyFunctions[OBJECTCLEAN] = objectStringify
typeStringifyFunctions[NONNULLOBJECTCLEAN] = objectStringify
typeStringifyFunctions[OBJECTCLEANORNOTHING] = objectStringify

#endregion

#endregion

############################################################
#region Error Codes
export NOTASTRING = 1000
export NOTANUMBER = 1001
export NOTABOOLEAN = 1002
export NOTANARRAY = 1003
export NOTANOBJECT = 1004

export INVALIDHEX = 1005
export INVALIDEMAIL = 1006
export INVALIDSIZE = 1007

export ISNAN = 1008
export ISNULL = 1009
export ISEMPTYSTRING = 1010
export ISEMPTYARRAY = 1011

export ISDIRTYSTRING = 1012
export ISDIRTYOBJECT = 1013
export ISNOTFINITE = 1014


export ISINVALID = 2222


############################################################
ErrorToMessage = Object.create(null)

ErrorToMessage[NOTASTRING] = "Not a String!"
ErrorToMessage[NOTANUMBER] = "Not a Number!"
ErrorToMessage[NOTABOOLEAN] = "Not a Boolean!"
ErrorToMessage[NOTANARRAY] = "Not an Array!"
ErrorToMessage[NOTANOBJECT] = "Not an Object!"
ErrorToMessage[INVALIDHEX] = "String is not valid hex!"
ErrorToMessage[INVALIDEMAIL] = "String is not a valid email!"
ErrorToMessage[INVALIDSIZE] = "String size mismatch!"
ErrorToMessage[ISNAN] = "Number is NaN!"
ErrorToMessage[ISNULL] = "Object is null!"
ErrorToMessage[ISEMPTYSTRING] = "String is empty!"
ErrorToMessage[ISEMPTYARRAY] = "Array is empty!"
ErrorToMessage[ISDIRTYSTRING] = "String is dirty!"
ErrorToMessage[ISDIRTYOBJECT] = "Object is dirty!"
ErrorToMessage[ISNOTFINITE] = "Number is infinity!"
ErrorToMessage[ISINVALID] = "Schema is invalid!"
#endregion

############################################################
#region Helpers
############################################################
isDirtyObject = (obj) ->
    return if obj == null
    ## as the inputs come from an object which was originalled paref from a JSON string we assume to not fall into an infinite loop
    keys = Object.keys(obj)
    for k in keys
        if k == "__proto__" or k == "constructor" or k == "prototype"
            return true
        if typeof obj[k] == "object"
            return true if isDirtyObject(obj[k])
    return false

############################################################
stringVerificationFunction = (str) ->
    return (arg) ->
        if arg != str then return ISINVALID
        return

############################################################
stringifyFunction = (type) ->
    fun = typeStringifyFunctions[type]
    if !fun? then throw new Error("Unrecognized Schematype! (#{type})")
    return fun

############################################################
validationFunction = (type) ->
    fun = typeValidationFunctions[type]
    if !fun? then throw new Error("Unrecognized Schematype! (#{type})")
    return fun

############################################################
createValidationFunctionForArray = (arr) ->
    if arr.length ==  0 then throw new Error("[] is illegal!")
    funcs = getValidationFunctionsForArray(arr)
    # olog valEntries
    
    func = (arg) ->
        if !Array.isArray(arg) then return ISINVALID
        hits = 0
        for f,i in funcs
            el = arg[i]
            if el? then hits++
            err = f(el)
            if err then return err
        
        if arg.length > hits then return ISINVALID
        return

    return func

createValidationFunctionForObject = (obj) ->
    # Obj is Schema Obj like obj = { prop1:STRING, prop2:NUMBER,... }
    if obj == null then throw new Error("null is illegal!")
    valEntries = getValidationEntriesForObject(obj)
    # olog valEntries
    if valEntries.length == 0 then throw new Error("{} is illegal!")
    
    func = (arg) ->
        # log "validating Object!"
        # olog arg
        if typeof arg != "object" then return ISINVALID
        if arg == null then return ISINVALID
        hits = 0
        for e in valEntries
            # olog e
            prop = arg[e[0]]
            if prop? then hits++
            err = e[1](prop)
            if err then return err
        
        keys = Object.keys(arg)
        if keys.length > hits then return ISINVALID
        # log "is valid!"
        return

    return func

############################################################
getValidationFunctionsForArray = (arr) ->
    funcs = new Array(arr.length)
    
    for el,i in arr
        switch
            when typeof el == "number" then funcs[i] = validationFunction(el)
            when typeof el == "string" then funcs[i] = onString(el)
            when typeof el != "object" then throw new Error("Illegal #{typeof el}!")
            when Array.isArray(el) 
                funcs[i] = createValidationFunctionForArray(el)
            else funcs[i] = createValidationFunctionForObject(el)

    return funcs

getValidationEntriesForObject = (obj) ->
    keys = Object.keys(obj)
    valEntries = []
    
    for k,i in keys
        prop = obj[k]
        if typeof prop == "number"
            valEntries.push([k, validationFunction(prop)])
            continue
        if typeof prop == "string"
            valEntries.push([k, onString(prop)])
            continue
        if typeof prop != "object" then throw new Error("Illegal #{typeof prop}!")
        if Array.isArray(prop)
            valFunc = createValidationFunctionForArray(prop)
            valEntries.push([k, valFunc])
        else 
            valFunc = createValidationFunctionForObject(prop)
            valEntries.push([k, valFunc])

    return valEntries

############################################################
createStringifyFunctionForArray = (arr) ->
    stringifyFunctions = getStringifyFunctionsForArray(arr)
    bufLen = stringifyFunctions.length
    buffer = new Array(bufLen)

    func = (arg) ->
        ## stringify contents with predefined functions
        buffer[i] = f(arg[i]) for f,i in stringifyFunctions

        ## cut off undefined tail
        while (buffer[buffer.length - 1] == undefined and buffer.length != 0)
            buffer.pop()

        ## fast return on no content
        if buffer.length == 0
            buffer.length = bufLen # restore original size
            return '[]' 

        # undefined within the array turns to 'null'
        for s,i in buffer when s == undefined
            buffer[i] = 'null'

        str = '['+ buffer[0]
        i = 1
        str += ','+buffer[i++] while(i < buffer.length)
        
        buffer.length = bufLen # restore original size
        str += ']'
        return str 

    return func

createStringifyFunctionForObject = (obj) ->
    sfEntries = getStringifyFunctionsForObject(obj) # stringify function entries
    bufLen = sfEntries.length
    buffer = new Array(bufLen)

    func = (arg) ->
        buffer[i] = el[1](arg[el[0]]) for el,i in sfEntries 

        # log "0"
        str = '{'
        i = 0
        
        while str.length == 1 and i < bufLen 
            str += '"'+sfEntries[i][0]+'":'+buffer[i] if buffer[i]?
            i++
        
        # log "1"
        while i < bufLen
            str += ',"'+sfEntries[i][0]+'":'+buffer[i] if buffer[i]?
            i++

        # log "2"
        str += '}'
        return str

    return func

############################################################
getStringifyFunctionsForArray = (arr) ->
    sfs = new Array(arr.length) ## stringify functions
    
    for el,i in arr
        type = typeof el
        if type == "number" then sfs[i] = stringifyFunction(el)
        if type == "string" then sfs[i] = stringifyFunction(STRING)
        if type != "object" then continue
        if Array.isArray(el) then sfs[i] = createStringifyFunctionForArray(el)
        else sfs[i] = createStringifyFunctionForObject(el)

    return sfs

getStringifyFunctionsForObject = (obj) ->
    keys = Object.keys(obj)
    sfes = new Array(keys.length) # stringify function entries 
    
    for k,i in keys
        prop = obj[k]
        type = typeof prop
        if type == "number" then sfes[i] = [k, stringifyFunction(prop)]
        if type == "string" then sfes[i] = [k, stringifyFunction(STRING)]
        if type != "object" then continue
        if Array.isArray(prop)
            sfes[i] = [k, createStringifyFunctionForArray(prop)] 
        else sfes[i] = [k, createStringifyFunctionForObject(prop)] 

    return sfes


#endregion

############################################################
#region local Variables
onString = null
locked = false

############################################################
numericOnlyRegex = /^\d+$/
invalidEmailSmallRegex = /(\.\.|--|-\.)|\.-/

############################################################
hexChars = "0123456789abcdefABCDEF"
hexMap = Object.create(null)
hexMap[c] = true for c in hexChars
# Object.freeze(hexMap)

############################################################
domainChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-."
domainCharMap = Object.create(null)
domainCharMap[c] = true for c in domainChars
# Object.freeze(domainCharMap)

############################################################
dirtyChars = "\x00\x01\x02\x03\x04\x05\x06\x07\x08" +  # ASCII control 0–8
    "\x0B\x0C" + # vertical tab, form feed
    "\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F" + # rest of controls
    "\x7F" +                                  # DEL
    "\u00A0" +                                # non-breaking space
    "\u1680" +                                # ogham space mark
    "\u180E" +                                # mongolian vowel separator
    "\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A" + # en/em/etc. spaces
    "\u200B\u200C\u200D\u200E\u200F" +        # zero-width spaces, joiners, directional
    "\u2028\u2029" +                          # line/paragraph separators
    "\u202A\u202B\u202C\u202D\u202E" +        # embedding/override control
    "\u2060\u2061\u2062\u2063\u2064\u2066\u2067\u2068\u2069" + # invisible controls
    "\u3000" +                                # ideographic space
    "\uFEFF"; 
dirtyCharMap = Object.create(null)
dirtyCharMap[c] = true for c in dirtyChars
# Object.freeze(dirtyCharMap)

#endregion

############################################################
## takes your schema
## returns the stringifier function
export createStringifier = (schema) ->
    type = typeof schema

    if type == "number" then return stringifyFunction(schema) 
    if type == "string" then return stringifyFunction(STRING)
    if Array.isArray(schema) then return createStringifyFunctionForArray(schema)
    else return createStringifyFunctionForObject(schema)

############################################################
## takes schema and optional boolean staticStrings
##    a truthy staticStrings allows you to put static 
##    strings into your schema like {userInpput: STRING, publicAccess: "onlywithexactlythisstring"}
## returns the validator function
export createValidator = (schema, staticStrings) ->
    
    if staticStrings then onString = stringVerificationFunction
    else onString = (schema) -> throw new Error("Illegal string!")

    type = typeof schema

    if type == "number" then return validationFunction(schema)
    if type == "string" then return onString(schema)
    if type != "object" then throw new Error("Illegal #{typeof schema}!")
    if Array.isArray(schema) then return createValidationFunctionForArray(schema)
    else return createValidationFunctionForObject(schema)

############################################################
## takes errorcode
## returns the associated errorMessage or ""
export getErrorMessage = (errorCode) ->
    msg = ErrorToMessage[errorCode]
    if typeof msg != "string" then return ""
    else return msg

############################################################
## takes a validatorFunction and stringifyFunction
##    this function cannot overwrite predefined types 
## returns the new enumeration number for the defined Type
export defineNewType = (validatorFunc, stringifyFunc) ->
    if locked then throw new Error("We are closed!")    
    newTypeId = typeValidationFunctions.length
    if newTypeId >= 1000 then throw new Error("Exeeding type limit!")
    typeValidationFunctions[newTypeId] = validatorFunc
    typeStringifyFunctions[newTypeId] = stringifyFunc
    return newTypeId

############################################################
## takes errorCode and errorMessage
##     this function cannot overwrite predefined ErrorCodes
## returns the new errorCode for the defined Error
export defineNewError = (errorMessage) ->
    if locked then throw new Error("We are closed!")
    errorCode = Object.keys(ErrorToMessage).length + 1000
    if errorCode >= 2000 then throw new Error("Exeeding error code limit!")
    if typeof errorMessage != "string" then throw new Error("ErrorMessage not a String!")
    ErrorToMessage[errorCode] = errorMessage
    return errorCode

############################################################
## takes a type, validatorFunc and stringifyFunc
##     sets the specified functions as validator and stringifier 
##     for the given type
export setTypeFunctions = (type, valiatorFunc, stringifyFunc) ->
    if locked then throw new Error("We are closed!")
    if typeof type != "number" then throw new Error("type is not a Number!")
    if type >= typeValidationFunctions.length or type < 1 
        throw new Error("Type does not exist!")
    
    if valiatorFunc?  and typeof valiatorFunc  != "function" 
        throw new Error("validatorFunc is not a Function!")
    if stringifyFunc? and typeof stringifyFunc  != "function" 
        throw new Error("stringifyFunc is not a Function!")

    if validatorFunction? then typeValidationFunctions[type] = validatorFunc
    else typeValidationFunctions[type] = () -> return

    if stringifyFunc? then typeStringifyFunctions[type] = stringifyFunc
    else typeStringifyFunctions[type] = () -> ""
    return 

############################################################
## locks/freezes all internal maps no mutation after this!
export lock = ->
    locked = true
    Object.freeze(typeValidationFunctions)
    Object.freeze(typeStringifyFunctions)
    Object.freeze(ErrorToMessage)
    return
