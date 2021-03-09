
![IPFS http logo](https://user-images.githubusercontent.com/1211152/29604883-ca3a4028-87e0-11e7-9f9a-75de49b06048.png)

# Lua-ipfs
Lua Ipfs http client library, partialy implemented.

You need go-ipfs running in the background to use this module. Currently, it has only been tested with the Go implementation of ipfs.


## Install

Via LuaRocks :

`luarocks install luaipfs`  


Or compile it yourself (using make). You will need [libcurl](https://curl.se/libcurl/) (C library), [luajson](https://luarocks.org/modules/harningt/luajson), [lpeg](https://luarocks.org/modules/gvvaughan/lpeg), [luafilesystem](https://luarocks.org/modules/hisham/luafilesystem), [base64](https://luarocks.org/modules/iskolbin/base64) and [lua-protobuf](https://luarocks.org/modules/xavier-wang/lua-protobuf).



## Usage

Create a new ipfs object:
```lua
local luaipfs = require("luaipfs")

local ipfs = luaipfs:new()
```

And download a file from ifps:
```lua
local file = io.open("quick-start", "w+")
file:write(
   ipfs:cat("/ipfs/QmQPeNsJPyVWPFDVHb77w8G42Fvo15z4bG2X8D2GhfbSXc/quick-start")
)
file:close()
```


## Documentation

See *[doc/luaipfs.md](doc/luaipfs.md)* for a list of available functions. You can find some examples *[here](examples/)*. 

Or use `luarocks doc luaipfs`

You can find the reference API on the ipfs website: https://docs.ipfs.io/reference/http/api/


