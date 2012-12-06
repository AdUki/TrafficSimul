#include <stdio.h>

#include "main.h"

/* assume that table is on the stack top */
int getfield (lua_State *L, const char *key)
{
	int result;
	
	lua_pushstring(L, key);
	lua_gettable(L, -2); /* get background[key] */
	
	result = lua_tointeger(L, -1);
	
	lua_pop(L, 1); /* remove number */
	return result;
}


void execLua(int argc, char **argv)
{
	int error;

	/* opens Lua */
	L = luaL_newstate();

	/* opens the standard libraries */
	luaL_openlibs(L);

	error = 
		/* load lua init file*/
		luaL_loadfile(L, "engine.luac") ||
		/* execute file */
		lua_pcall(L, 0, 0, 0);
	
	if (error) {
		fprintf(stderr, "%s", lua_tostring(L, -1));
		lua_pop(L, 1); /* pop error message from the stack */
	}
	
	// push C arguments to lua state
	switch(argc) {
		case 3:
			printf("Setting car arrivals to: %s\n", argv[2]);
			lua_getglobal(L, argv[2]);
			lua_pushvalue(L, -1);
			lua_setglobal(L, "defaultArrive");
		case 2:
			printf("Seting car behavior to: %s\n", argv[1]);
			lua_getglobal(L, argv[1]);
			lua_pushvalue(L, -1);
			lua_setglobal(L, "defaultBehaviour");
	}
	
	return;
}

int main(int argc, char **argv)
{
	printf("C: Initializing LUA\n");
	execLua(argc, argv);
	
	printf("C: Initializing Allegro\n");
	execAlleg();
	
	lua_close(L);
	
	return 0;
}

