

print("--start--")
-- my_string = NSString("alloc")("init");
my_object = ObjCTest("alloc")("init")

--[[
number = my_object("memberMethodWithNumber:", 42)
print("NSNumber")
print(number);

number = my_object("memberMethodWithInt:", 42)
print("int")
print(number);

]]

new_pointer = my_object("memberMethodWithPointer:", my_object)
number = new_pointer("memberMethodWithInt:", 44)

print(number);

print("--end--")


function TestVoidFunction(in_string, in_number, in_bool)
    print('function test')
    print(type(in_string))
    print(in_string)
    print(type(in_number))
    print(in_number)
    print(type(in_bool))
    print(in_bool)
end

function TestNumberFunction(in_string, in_number, in_bool)
    print('function test')
    print(type(in_string))
    print(in_string)
    print(type(in_number))
    print(in_number)
    print(type(in_bool))
    print(in_bool)
    return in_number
end

function TestBoolFunction(in_string, in_number, in_bool)
    print('function test')
    print(type(in_string))
    print(in_string)
    print(type(in_number))
    print(in_number)
    print(type(in_bool))
    print(in_bool)
    return in_bool
end

function TestStringFunction(in_string, in_number, in_bool)
    print('function test')
    print(type(in_string))
    print(in_string)
    print(type(in_number))
    print(in_number)
    print(type(in_bool))
    print(in_bool)
    return in_string
end