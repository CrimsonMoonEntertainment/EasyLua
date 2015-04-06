EasyLua
======================
EasyLua is an easy to integrate and easy to use library for bridging Obj-C and Lua.
Our goal was to make a library which is easy to call into lua and out
to iOS with no knowlege required of how the lua c bridge worked. An emphesis was
placed on also making the lua code readable when using objective-c classes

No initialization is needed on the iOS side. Examples within objective-c:

    [[EasyLua sharedEasyLua] runLuaString:@"print(\"Hello World\")"];
    [[EasyLua sharedEasyLua] runLuaBundleFile:@"MyCode.lua"]

All Objective-c classes in the binary are available for use in lua. Some Example lua code:

    instance = MyClassName('alloc')('init')
    instance('methodName:', 'param_1')
    instance('methodName:param2name:', 'param_1', 'param_2')

When calling methods, Lua stirngs are automatically converted into NSStrings and numebrs, if needed will be converted to NSNumbers. Additionally, NSObject are wrapped and unwrapped as needed when being sent between the two environments 

Dictionaries can also be used similar to how they are used in Objective-C:

    new_dict = NSMutableDictionary('alloc')('init')
    new_dict['ReturnKey'] = 'ReturnValue'

Additionally, tables will be converted into either NSArrays or NSDictionaries when returned or called as parameters to an Objective-C method.


EasyLua was originally derived from Lua-Objective-C Bridge. Special thanks to the original author Toru Hisai!

Current Limitations
=======
Currently, calling a method such as this will fail:

	NSString('alloc')('init')

This is because strings are converted into lua strings right away, so when you all init, it does not know what to do. This can be fixed in the future but should generally not be needed as you can simply use lua string.


License
=======
Copyright for portions of project EasyLua held by Toru Hisai, 2015

All Other Copyright for EasyLua held by Crimson Moon Entertainment LLC, 2015

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Author
======
EasyLua: David Holtkamp david@crimson-moon.com

Lua-Objective-C Bridge Author: Toru Hisai toru@torus.jp @torus 
