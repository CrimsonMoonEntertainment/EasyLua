--
-- Objective-C Classes
--

stack = objc.newstack()

function sendMesg (target, selector, ...)
   local n = select("#", ...)
   for i = 1, n do
      local arg = select(-i, ...)
      objc.push(stack, arg)
   end
   objc.push(stack, target, selector)
   objc.operate(stack, "call")
   return objc.pop(stack)
end


function attachObjCMetatable(obj)
    local o = {}
    setmetatable(o, {__call = function (func, ...)
                                -- print("obj called!", func, obj)
                                local ret = sendMesg(obj, ...)
                                if type(ret) == "userdata" then
                                   return attachObjCMetatable(ret)
                                else
                                   return ret
                                end
                             end,
                             __unm = function (op)
                               return obj
                            end})
    return o
end


function getUnknownVariable(tbl, key)
    local cls = objc.getclass(key)
    cls = attachObjCMetatable(cls)
    tbl[key] = cls
    return cls
end


setmetatable(_G, {__index=getUnknownVariable})