/* Copyright © 2018 Neph <neph@crypt.lol>
   This program is free software. It comes without any warranty, to
   the extent permitted by applicable law. You can redistribute it
   and/or modify it under the terms of the Do What The Fuck You Want
   To Public License, Version 2, as published by Sam Hocevar. 
   See the LICENSE file for more details. */

#include "http.h"



int retrieve_url (lua_State *L) {
   lua_pushstring(L, "http://");

   lua_pushstring(L, "server");
   lua_gettable(L, 1);

   lua_pushstring(L, ":");

   lua_pushstring(L, "port");
   lua_gettable(L, 1);

   lua_rotate(L, 2, -1);

   lua_concat(L, 5);

   return 1;
}

