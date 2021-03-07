
LUA_VER=lua5.3
LUA_LIBS=`pkg-config --libs $(LUA_VER)`
LUA_INCL=`pkg-config --cflags $(LUA_VER)`

CURL=libcurl
CURL_LIBS=`pkg-config --libs $(CURL)`

MOD_INCL=include


RPATH=.:lib/:../lib
LFLAG=-Wl,-rpath="$(RPATH)"



All: modhttp

modhttp:
	cd luaipfs && gcc -fPIC -shared -o http.so src/*.c -I$(MOD_INCL) $(LUA_LIBS) $(LUA_INCL) $(CURL_LIBS) $(LFLAG) -Wall

clean:
	cd luaipfs && test -f http.so && rm -f http.so || test 0
	cd luaipfs && rm -f src/*.o
