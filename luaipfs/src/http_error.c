/* Copyright © 2018 Neph <neph@crypt.lol>
   This program is free software. It comes without any warranty, to
   the extent permitted by applicable law. You can redistribute it
   and/or modify it under the terms of the Do What The Fuck You Want
   To Public License, Version 2, as published by Sam Hocevar. 
   See the LICENSE file for more details. */

#include "http.h"


/*
   Errors functions
*/

void arg_module_error (lua_State *L, int pos, int idx, char *exp_type) {
   luaL_error(L, "Invalid argument #%d (%s expected, got %s)", 
      pos, exp_type, lua_typename(L, lua_type(L, idx)));
}


void module_error (lua_State *L, char *err) {
   luaL_error(L, "Fatal: %s", err);
}

