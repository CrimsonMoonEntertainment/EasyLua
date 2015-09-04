

my_object = ObjCTest("alloc")("init")


function TestDict( dictIN )
    local my_table = {}
    my_table['TestKey'] = dictIN['TestKey']
    return my_table
end

function TestArray(val)
    local my_table = {}
    my_table[1] = val('objectAtIndex:', 0)
    my_table[2] = val('objectAtIndex:', 1)
    return my_table
end

function SetTestValue(val)
    ObjCTest("setLastTestState:", val)
end

function TestGlobals()
    if new_global ~= 'Global String' then
        print('did not set global!')
        SetTestValue(false)
        return
    end

    lua_new_global = 'lua_global_string'
    SetTestValue(true)
end


function TestMultiValueCalls()
    num = ObjCTest("multiValueTest:value2:", 25, 6)  -- 2 * v1 + v2

    if num ~= 56 then
        SetTestValue(false)
        print('Failed multi value')
        return
    end

    SetTestValue(true)
end


function TestNSDictionay(dict)

    if dict['TestKey'] == 'TestValue' then
        SetTestValue(true)
    else
        print 'Failed to read dict'
    end

    new_dict = NSMutableDictionary('alloc')('init')
    new_dict['ReturnKey'] = 'ReturnValue'
    return new_dict
end


function TestKeyPaths(dict)
    return dict['TestKey1.TestKey2']
end


function TestObjects(val)
    val("instanceSetLastTestState:", true)    
    return val
end

function TestGettingBool()
    local val = ObjCTest("returnBoolValue:", true)
    if val == false then
        SetTestValue(false)
        return
    end

    val = ObjCTest("returnBoolValue:", false)
    if val == true then
        SetTestValue(false)
        return
    end

    local val = ObjCTest("returnBoolValueAsNSNumber:", true)
    if val == false then
        SetTestValue(false)
        return
    end

    val = ObjCTest("returnBoolValueAsNSNumber:", false)
    if val == true then
        SetTestValue(false)
        return
    end

    SetTestValue(true)
end

function TestBoolTypes()

    local val = ObjCTest("returnBoolValue:", true)
    if type(val) ~= 'boolean' then
        print('failed bool type')
        print(type(val))
        SetTestValue(false)
        return
    end

    val = ObjCTest("returnBoolValueAsNSNumber:", true)
    if type(val) ~= 'boolean' then
        print('failed NSNumebr type')
        print(type(val))
        SetTestValue(false)
        return
    end
    SetTestValue(true)
end


function TestStrings()
    local val = ObjCTest("returnStringValue:", "TestString")
    if val ~= "TestString" then
        print('failed string')
        print(type(val))
        print(val)
        SetTestValue(false)
        return
    end

    SetTestValue(true)
end


function TestVoidFunction(in_string, in_number, in_bool)

end

function TestNumberFunction(in_string, in_number, in_bool)
    return in_number
end

function TestBoolFunction(in_string, in_number, in_bool)
    return in_bool
end

function TestStringFunction(in_string, in_number, in_bool)
    return in_string
end


function TestVector3ReadAndWrite(in_obj)
    return in_obj.Vector3
end

function TestVector4ReadAndWrite(in_obj)
    return in_obj.Vector4
end


