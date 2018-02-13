/* Copyright © 2018 Neph <neph@crypt.lol>
   This program is free software. It comes without any warranty, to
   the extent permitted by applicable law. You can redistribute it
   and/or modify it under the terms of the Do What The Fuck You Want
   To Public License, Version 2, as published by Sam Hocevar. 
   See the LICENSE file for more details. */



#ifndef _http_h
#define _http_h


#include <stdlib.h>

#include <stdio.h>

#include <string.h>

#include <fcntl.h>

#include <unistd.h>

#include <errno.h>

#include <sys/types.h>

#include <sys/stat.h>

#include <lua.h>

#include <luaconf.h>

#include <lauxlib.h>

#include <curl/curl.h>




#define ERR_MAX_SIZE 512




struct http_header {
   char *headers[128];
   size_t tot_items;
};

typedef struct http_header http_header;



struct writeback_base {
   size_t filesize;
   http_header hs;
   int error;
   char error_str[ERR_MAX_SIZE];
   size_t error_str_size;
};

typedef struct writeback_base writeback_base;



struct writeback_buffer {
   writeback_base base;
   int fd;
   char *data;
   size_t size;
   size_t free;
};

typedef struct writeback_buffer writeback_buffer;



struct writeback_luacb {
   writeback_base base;
   lua_State *L;
   char *ipfs_path;
};

typedef struct writeback_luacb writeback_luacb;






int luaopen_ipfs_http (lua_State *);


size_t cb_write_to_buffer (char *, size_t, size_t, void *);

size_t cb_write_to_file (char *, size_t, size_t, void *);

size_t cb_write_to_luacb (char *, size_t, size_t, void *);

size_t cb_header_func_3 (char *, size_t, size_t, void *);





void module_error(lua_State *L, char *);

void arg_module_error (lua_State *, int, int, char *);



int retrieve_url (lua_State *);



#endif
