--
-- Objective-C Classes
--

-- Send Objective-C Messages 
function sendMesg (target, selector, ...)
   local to_send = {}
   local n = select("#", ...)
   for i = 1, n do
      local arg = select(-i, ...)

      -- If this is a wrapped object, then send what is in the wrapper
      arg = unwrap(arg)
      table.insert(to_send, arg)
   end
   
   table.insert(to_send, target)
   table.insert(to_send, selector)
   
   return objc.call(to_send)
end


-- Wrap Objective-C Pointers
function wrap(obj)
    local o = {}
    o["WrappedObject"] = obj;
    setmetatable(o, {__call = function (func, ...)
                                -- print("obj called!", func, obj)
                                local ret = sendMesg(obj, ...)
                                if type(ret) == "userdata" then
                                   return wrap(ret)
                                else
                                   return ret
                                end
                             end,
                    __index = function(inObject, inKey)
                                local ret = sendMesg(inObject["WrappedObject"], 'valueForKeyPath:', inKey)
                                if type(ret) == "userdata" then
                                   return wrap(ret)
                                else
                                   return ret
                                end
                              end,
                    __newindex =  function(inObject, inKey, inValue)
                                    sendMesg(inObject["WrappedObject"], 'setValue:forKeyPath:', inValue, inKey)
                                  end



                              })
    return o
end

-- Unwrap Objective-C Pointers
function unwrap(obj)
  if type(obj) == "table" then
      if obj["WrappedObject"] ~= nil then
        return obj["WrappedObject"]
      end
  end

  return obj
end

-- Looks for Objective-C class if variable is not found in global space
function getUnknownVariable(tbl, key)
    local cls = objc.getclass(key)
    cls = wrap(cls)
    tbl[key] = cls
    return cls
end


setmetatable(_G, {__index=getUnknownVariable})