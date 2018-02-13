All: modhttp

modhttp:
	cd luaipfs && gcc -fPIC -shared -o http.so src/*.c -Iinclude `pkg-config --libs lua` `pkg-config --libs libcurl` -Wl,-rpath=".:lib/:../lib" -Wall

clean:
	cd luaipfs && test -f http.so && rm -f http.so || test 0
	cd luaipfs && rm -f src/*.o