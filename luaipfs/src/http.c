/* Copyright © 2018 Neph <neph@crypt.lol>
   This program is free software. It comes without any warranty, to
   the extent permitted by applicable law. You can redistribute it
   and/or modify it under the terms of the Do What The Fuck You Want
   To Public License, Version 2, as published by Sam Hocevar. 
   See the LICENSE file for more details. */


#include "http.h"


static int ipfs_http_new (lua_State *);

static int ipfs_http_get (lua_State *);

static int ipfs_http_get_cb (lua_State *);

static int ipfs_post_multipart_data (lua_State *);


static const struct luaL_Reg ipfs_http[] = {
   { "new", ipfs_http_new },
   { "get", ipfs_http_get },
   { "get_cb", ipfs_http_get_cb },
   { "post_multipart_data", ipfs_post_multipart_data },
   { NULL, NULL }
};




static int clean_curl_ctx (lua_State *L);






static int ipfs_http_new (lua_State *L) {
   int top;

   lua_checkstack(L, 5);
   top = lua_gettop(L);

   //Verify args

   if (lua_type(L, 1) != LUA_TTABLE)
      arg_module_error(L, 1, 1, "self (table)");
   else if (top > 1 && lua_type(L, 2) != LUA_TTABLE)
      arg_module_error(L, 2, 2, "table");



   //Verify if optional user option (base object) is present or create new object (empty table)

   if (top <= 1)
      lua_createtable(L, 0, 2);



   //Set __index metamethod in http module to point to himself

   lua_pushstring(L, "__index");
   lua_pushvalue(L, 1);
   lua_settable(L, 1);



   //Set object metatable (http module table) and return new object

   lua_pushvalue(L, 1);
   lua_setmetatable(L, -2);


   return 1;
}





static int ipfs_http_get (lua_State *L) {
   CURL *curl; CURLcode ret;
   const char *url;
   writeback_buffer buffer = {'\x00'};
   int i; int fd = 0; int timeout;


   lua_checkstack(L, 6);


   //Verify needed args (self obj and request)

   if (lua_type(L, 1) != LUA_TTABLE)
      arg_module_error(L, 1, 1, "self (table)");
   else if (lua_type(L, 2) != LUA_TSTRING)
      arg_module_error(L, 2, 2, "string");
   else if (lua_type(L, 3) != LUA_TNIL && lua_type(L, 3) != LUA_TNONE 
   && lua_type(L, 3) != LUA_TSTRING) {
      arg_module_error(L, 3, 3, "string");
   }



   //Open fd for writing if filepath is set

   if (lua_type(L, 3) == LUA_TSTRING) {
      fd = open(lua_tostring(L, 3), O_RDWR|O_CREAT|O_TRUNC, S_IWUSR|S_IRUSR|S_IRGRP);
      buffer.fd = fd;
      if (fd == -1) {
         lua_pushboolean(L, 0);
         lua_pushstring(L, strerror(errno));
         return 2;
      }
   }


   //Retrieve server addr and port from obj

   lua_pushcfunction(L, retrieve_url);
   lua_pushnil(L);
   lua_copy(L, 1, -1); //Copy self table on top
   lua_pushnil(L);
   lua_copy(L, 2, -1); //Copy api string args on top
   lua_pcall(L, 2, 1, 0);

   url = lua_tostring(L, -1);


   //Retrieve timeout value

   lua_pushstring(L, "timeout");
   lua_gettable(L, 1);
   (lua_type(L, -1) == LUA_TNUMBER) ? 
      (timeout = lua_tointeger(L, -1)) : (timeout = 120);
   lua_pop(L, 1);



   //Init curl request

   curl = curl_easy_init();
   if (!curl)
      module_error(L, strerror(errno));



   //Set curl options

   curl_easy_setopt(curl, CURLOPT_URL, url);
   curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 1);
   curl_easy_setopt(curl, CURLOPT_LOW_SPEED_LIMIT, 50);
   curl_easy_setopt(curl, CURLOPT_LOW_SPEED_TIME, timeout);

   if (!fd)
      curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, cb_write_to_buffer);
   else
      curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, cb_write_to_file);
   curl_easy_setopt(curl, CURLOPT_WRITEDATA, &buffer);


   curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, cb_header_func_3);
   curl_easy_setopt(curl, CURLOPT_HEADERDATA, &buffer);




   //Perform request, return answer||true||false and http response code + optional err

   ret = curl_easy_perform(curl);
   if (ret != CURLE_OK && ret != CURLE_OPERATION_TIMEDOUT)
      module_error(L, (char *)curl_easy_strerror(ret));


   if (buffer.base.hs.tot_items < 1 || buffer.base.error || ret == CURLE_OPERATION_TIMEDOUT) {
      lua_pushboolean(L, 0);
   } else {
      if (!fd)
         lua_pushlstring(L, buffer.data, buffer.size - buffer.free);
      else
         lua_pushboolean(L, 1);
   }



   //Push http return code
   
   lua_pushstring(L, buffer.base.hs.headers[0]);


   //Push error message if there is one or nil

   if (ret == CURLE_OPERATION_TIMEDOUT) {
      lua_pushstring(L, "timeout was reached");
   } else if (strncmp(buffer.base.hs.headers[0], "HTTP/1.1 500", 12) == 0) {
      if (buffer.base.error_str_size > 0)
         lua_pushstring(L, buffer.base.error_str);
      else
         lua_pushnil(L);
   } else {
      lua_pushnil(L);
   }


   //Free allocated memory

   for (i = 0; i < buffer.base.hs.tot_items; i++)
      free(buffer.base.hs.headers[i]);


   curl_easy_cleanup(curl);

   if (buffer.data)
      free(buffer.data);
   if (fd)
      close(fd);


   //Remove file in case of error

   if (buffer.base.error && fd)
      unlink(lua_tostring(L, 3));


   return 3;
}






static int ipfs_http_get_cb (lua_State *L) {
   CURL *curl; CURLcode ret;
   int i; const char *url;
   writeback_luacb cb = {'\x00'};
   int timeout;


   lua_checkstack(L, 8);
 
    //Verify needed args (self obj and request)

   if (lua_type(L, 1) != LUA_TTABLE)
      arg_module_error(L, 1, 1, "self (table)");
   else if (lua_type(L, 2) != LUA_TSTRING)
      arg_module_error(L, 2, 2, "string");
   else if (lua_type(L, 3) != LUA_TSTRING)
      arg_module_error(L, 3, 3, "string");
   else if (lua_type(L, 4) != LUA_TFUNCTION)
      arg_module_error(L, 4, 4, "function");
   
   cb.L = L;
   cb.ipfs_path = (char *)lua_tostring(L, 3);


   //Retrieve server addr and port from obj

   lua_pushcfunction(L, retrieve_url);
   lua_pushnil(L);
   lua_copy(L, 1, -1); //Copy self table on top
   lua_pushnil(L);
   lua_copy(L, 2, -1); //Copy api string args on top
   lua_pcall(L, 2, 1, 0);

   url = lua_tostring(L, -1);

   //Retrieve timeout value

   lua_pushstring(L, "timeout");
   lua_gettable(L, 1);
   (lua_type(L, -1) == LUA_TNUMBER) ? 
      (timeout = lua_tointeger(L, -1)) : (timeout = 120);
   lua_pop(L, 1);


   //Init curl request

   curl = curl_easy_init();
   if (!curl)
      module_error(L, strerror(errno));


   //Add callback function to lua register

   lua_pushstring(L, "lua_cb_func");
   lua_pushnil(L);
   lua_copy(L, 4, -1);
   lua_settable(L, LUA_REGISTRYINDEX);




   //Set curl options

   curl_easy_setopt(curl, CURLOPT_URL, url);
   curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 1);
   curl_easy_setopt(curl, CURLOPT_LOW_SPEED_LIMIT, 50);
   curl_easy_setopt(curl, CURLOPT_LOW_SPEED_TIME, timeout);

   curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, cb_write_to_luacb);
   curl_easy_setopt(curl, CURLOPT_WRITEDATA, &cb);
   
   curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, cb_header_func_3);
   curl_easy_setopt(curl, CURLOPT_HEADERDATA, &cb);



   //Perform request, return true||false and http response code + optional err

   ret = curl_easy_perform(curl);
   if (ret != CURLE_OK && ret != CURLE_OPERATION_TIMEDOUT)
      module_error(L, (char *)curl_easy_strerror(ret));


   if (cb.base.hs.tot_items < 1 || cb.base.error || ret == CURLE_OPERATION_TIMEDOUT)
      lua_pushboolean(L, 0);
   else
      lua_pushboolean(L, 1);


   //Push http return code
   
   lua_pushstring(L, cb.base.hs.headers[0]);



   //Push error message if there is one or nil

   if (ret == CURLE_OPERATION_TIMEDOUT) {
      lua_pushstring(L, "timeout was reached");
   } else if (strncmp(cb.base.hs.headers[0], "HTTP/1.1 500", 12) == 0) {
      if (cb.base.error_str_size)
         lua_pushstring(L, cb.base.error_str);
      else
         lua_pushnil(L);
   } else {
      lua_pushnil(L);
   }

   //Free allocated memory

   for (i = 0; i < cb.base.hs.tot_items; i++)
      free(cb.base.hs.headers[i]);

   curl_easy_cleanup(curl);

   return 3;
}






static int ipfs_post_multipart_data (lua_State *L) {
   const char *filepath;
   const char *filemode;
   const char *filename;
   const char *url;
   int items_tot;
   
   CURL *curl; CURLcode ret;
   writeback_buffer buffer = {'\x00'};
   curl_mime *mime; curl_mimepart *part;
   char p[8] = {'\x00'};
   int retcode; int i; char *ptr;


   lua_checkstack(L, 10);


   //Verify args and retrieve filepath

   if (lua_type(L, 1) != LUA_TTABLE)
      arg_module_error(L, 1, 1, "self (table)");
   else if (lua_type(L, 2) != LUA_TSTRING)
      arg_module_error(L, 2, 2, "string");
   else if (lua_type(L, 3) != LUA_TTABLE)
      arg_module_error(L, 3, 3, "table");


   
   //Retrieve server addr and port from obj

   lua_pushcfunction(L, retrieve_url);
   lua_pushnil(L);
   lua_copy(L, 1, -1); //Copy self table on top
   lua_pushnil(L);
   lua_copy(L, 2, -1); //Copy api string args on top
   lua_pcall(L, 2, 1, 0);

   url = lua_tostring(L, -1);




   //Push files list on top of the stack and retrieve items count

   lua_rotate(L, 3, -1);
   lua_len(L, -1);
   
   items_tot = lua_tointeger(L, -1);
   lua_pop(L, 1);



   //Init curl ctx

   curl = curl_easy_init();
   if (!curl)
      module_error(L, strerror(errno));

   
   //Set curl options

   curl_easy_setopt(curl, CURLOPT_URL, url);
   curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 1);
   curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, cb_write_to_buffer);
   curl_easy_setopt(curl, CURLOPT_WRITEDATA, &buffer);
   curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, cb_header_func_3);
   curl_easy_setopt(curl, CURLOPT_HEADERDATA, &buffer);

   //Prepare multipart post

   mime = curl_mime_init(curl);


   for (i = 1; i <= items_tot; i++) {
      part = curl_mime_addpart(mime);

      //Retrieve current file attr table on top of stack
      lua_pushinteger(L, i);
      lua_gettable(L, -2);


      //Retrieve file's type, filename and path

      lua_pushstring(L, "mode");
      lua_gettable(L, -2);

      filemode = lua_tostring(L, -1);

      lua_pushstring(L, "filename");
      lua_gettable(L, -3);

      filename = lua_tostring(L, -1);

      lua_pushstring(L, "path");
      lua_gettable(L, -4);

      filepath = lua_tostring(L, -1);

      if (strncmp(filemode, "directory", 9) == 0) {
         curl_mime_filename(part, filename);
         curl_mime_type(part, "application/x-directory");
      } else {
         curl_mime_filedata(part, filepath);
         curl_mime_filename(part, filename);
      }

      //Clean stack: pop filepath, name, mode and file attr table

      lua_pop(L, 4);
   }


   curl_easy_setopt(curl, CURLOPT_MIMEPOST, mime);



   //Perform request, return answer||false and http response code/error
   //If we find a 100 Continue here (with an error), server wait for post data. So there's something 
   //wrong with files to upload. But it's a non fatal error.

   ret = curl_easy_perform(curl);
   if (ret != CURLE_OK) {
      if (strncmp(buffer.base.hs.headers[0], "HTTP/1.1 100 Continue", 21) != 0) 
         module_error(L, (char *)curl_easy_strerror(ret));
      else {
         ptr = (char *)curl_easy_strerror(ret);
         strncpy(buffer.base.error_str, ptr, strnlen(ptr, ERR_MAX_SIZE - 1));
         buffer.base.error = 1;
         retcode = 100;
      }
   }


   //Search for http return with a value greater than or equal to 400 in headers

   if (buffer.base.error || !buffer.base.hs.tot_items) {
      lua_pushboolean(L, 0);
      if (retcode == 100)
         lua_pushstring(L, buffer.base.error_str);
      else {
         for (i = 0; i < buffer.base.hs.tot_items; i++) {
            if (strncmp(buffer.base.hs.headers[i], "HTTP/1.1", 8) == 0) {
               strncpy(p, (buffer.base.hs.headers[i]) + 9, 3);
               retcode = atoi(p);

               if (retcode >= 400) {
                  lua_pushstring(L, buffer.base.hs.headers[i]);
                  break;
               }
            }
         }
      }
   } else {
      lua_pushlstring(L, buffer.data, buffer.size - buffer.free);
      lua_pushstring(L, "HTTP/1.1 200 OK");
   }


   //Free allocated memory/object

   for (i = 0; i < buffer.base.hs.tot_items; i++)
      free(buffer.base.hs.headers[i]);

   curl_mime_free(mime);

   curl_easy_cleanup(curl);

   if (buffer.data)
      free(buffer.data);
   

   return 2;
}







/*
   __gc metamethod module function
*/

static int clean_curl_ctx (lua_State *L) {
   
   //Terminate curl global context

   curl_global_cleanup();


   return 0;
}






/*
   Module entry point
*/

int luaopen_luaipfs_http (lua_State *L) {

   lua_checkstack(L, 5);

   //Init global curl context

   curl_global_init(CURL_GLOBAL_ALL);


   //Create metatable and add finalizer method to it

   lua_createtable(L, 0, 1);
   lua_pushstring(L, "__gc");
   lua_pushcfunction(L, clean_curl_ctx);
   lua_settable(L, -3);


   //Create/setmetatable

   luaL_newlib(L, ipfs_http);

   lua_rotate(L, -2, 1);
   lua_setmetatable(L, -2);


   //Add default options to module instance and return it

   lua_pushstring(L, "server");
   lua_pushstring(L, "localhost");
   lua_settable(L, -3);

   lua_pushstring(L, "port");
   lua_pushstring(L, "5001");
   lua_settable(L, -3);

   

   return 1;
}
