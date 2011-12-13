#ifndef MAIN_H
#define MAIN_H

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

lua_State *L;

int getfield (lua_State *L, const char *key);
int execAlleg();


#endif // MAIN_H
