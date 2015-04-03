//
//  LuaBridgedFunctions.h
//  Pods
//
//  Created by David Holtkamp on 4/1/15.
//
//


#ifdef __cplusplus
extern "C" {
#endif

#import "lua.h"

#ifdef __cplusplus
}
#endif

#pragma mark - Helper Functions
bool to_lua(lua_State *L, id obj, bool dowrap);
id from_lua(lua_State *L, int index);


#pragma mark - Lua Registerd Functions
int luafunc_newstack(lua_State *L);
int luafunc_push(lua_State *L);
int luafunc_pop(lua_State *L);
int luafunc_call(lua_State *L);
int luafunc_clear(lua_State *L);
int luafunc_operate(lua_State *L);
int luafunc_getclass(lua_State *L);