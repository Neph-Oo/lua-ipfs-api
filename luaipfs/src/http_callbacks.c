/* Copyright © 2018 Neph <neph@crypt.lol>
   This program is free software. It comes without any warranty, to
   the extent permitted by applicable law. You can redistribute it
   and/or modify it under the terms of the Do What The Fuck You Want
   To Public License, Version 2, as published by Sam Hocevar. 
   See the LICENSE file for more details. */

#include "http.h"



/*
   Curl callbacks
*/


size_t cb_write_to_buffer (char *data, size_t block_size, size_t nbr_blocks, void *ud) {
	size_t old_size;
	writeback_buffer *buffer = (writeback_buffer *)ud;
   size_t real_size = block_size * nbr_blocks;

	//Verify there is no error
	//Else, add error string (data received) in ud and return

	if (buffer->base.error) {
		if (buffer->base.error_str_size + real_size < ERR_MAX_SIZE - 1) {
			memcpy(buffer->base.error_str + buffer->base.error_str_size, data, real_size);
			buffer->base.error_str_size += real_size;
		}
		return real_size;
	}


	old_size = buffer->size - buffer->free;

	if (buffer->free <= real_size) {
		buffer->size = (size_t)(4096 * ((size_t)((old_size + real_size) / 4096) + 1));
		
		buffer->data = (char *)realloc(buffer->data, buffer->size);
		if (!buffer->data)
			exit(EXIT_FAILURE); //tmp
	}


	buffer->free = buffer->size - (old_size + real_size);

	memcpy(buffer->data + old_size, data, real_size);


   return real_size;
}




size_t cb_write_to_file (char *data, size_t block_size, size_t nbr_blocks, void *ud) {
	ssize_t bytes_write;
	writeback_buffer *buffer = (writeback_buffer *)ud;
	int fd = buffer->fd;
	size_t real_size = block_size * nbr_blocks;

	//Verify there is no error
	//Else, add error string (data received) in ud and return

	if (buffer->base.error) {
		if (buffer->base.error_str_size + real_size < ERR_MAX_SIZE - 1) {
			memcpy(buffer->base.error_str + buffer->base.error_str_size, data, real_size);
			buffer->base.error_str_size += real_size;
		}
		return real_size;
	}


	do {
		bytes_write = write(fd, data, real_size);
		if (bytes_write <= 0) {
			if (errno == EINTR)
				continue;
			exit(EXIT_FAILURE); //tmp
		}
		break;
	} while (1);

	return bytes_write; //this should generate an error if not equal to real_size
}




size_t cb_write_to_luacb (char *data, size_t size, size_t nitems, void *ud) {
	writeback_luacb *cb = (writeback_luacb *)ud;
	lua_State *L = cb->L;
	char *ipfs_path = cb->ipfs_path;
	size_t filesize = cb->base.filesize;
	size_t real_size = size * nitems;

	//Verify there is no error
	//Else, add error string (data received) in ud and return

	if (cb->base.error) {
		if (cb->base.error_str_size + real_size < ERR_MAX_SIZE - 1) {
			memcpy(cb->base.error_str + cb->base.error_str_size, data, real_size);
			cb->base.error_str_size += real_size;
		}
		return real_size;
	}



	//Retrieve callback function from lua registry
	
	lua_pushstring(L, "lua_cb_func");
	lua_gettable(L, LUA_REGISTRYINDEX);

	//Push args

	lua_pushstring(L, ipfs_path);
	lua_pushlstring(L, data, real_size);
	lua_pushinteger(L, filesize);


	//Call user function

	lua_pcall(L, 3, 0, 0);


	return real_size;
}




size_t cb_header_func_3 (char *data, size_t size, size_t nitems, void *ud) {
	writeback_base *cb = (writeback_base *)ud;
	http_header *hs = &cb->hs;
	size_t real_size = size * nitems;
	char *ptr;

	if (hs->tot_items < 128) {
		hs->headers[hs->tot_items] = (char *)malloc((real_size * sizeof(char)) + 1);
		memcpy(hs->headers[hs->tot_items], data, real_size);
		*(hs->headers[hs->tot_items] + real_size - 1) = '\x00'; //replace line feed with null byte

		if (hs->tot_items == 0 && strncmp(hs->headers[0], "HTTP/1.1 200 OK", 15) != 0
		&& strncmp(hs->headers[0], "HTTP/1.1 100 Continue", 21) != 0) {
			cb->error = 1;
		} else if (strncmp(hs->headers[hs->tot_items], "X-Content-Length", 16) == 0) {
			for (ptr = hs->headers[hs->tot_items]; *ptr != '\x00'; ptr++) {
				if (*ptr == '\x20') {
					cb->filesize = (size_t)strtoul(ptr + 1, NULL, 10);
					break;
				}
			}
		}

		hs->tot_items++;
	}

	return real_size;
}

