--
-- Objective-C Classes
--

stack = objc.newstack()

function sendMesg (target, selector, ...)
   local n = select("#", ...)
   for i = 1, n do
      local arg = select(-i, ...)

      -- If this is a wrapped object, then send what is in the wrapper
      if type(arg) == "table" then
        if arg["WrappedObject"] ~= nil then
          arg = arg["WrappedObject"]
        end
      end

      objc.push(stack, arg)
   end
   objc.push(stack, target, selector)
   objc.operate(stack, "call")
   return objc.pop(stack)
end


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
                             end})
    return o
end

function unwrap(obj)
  return o["WrappedObject"]
end


function getUnknownVariable(tbl, key)
    local cls = objc.getclass(key)
    cls = wrap(cls)
    tbl[key] = cls
    return cls
end


setmetatable(_G, {__index=getUnknownVariable})