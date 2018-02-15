
![IPFS http logo](https://user-images.githubusercontent.com/1211152/29604883-ca3a4028-87e0-11e7-9f9a-75de49b06048.png)

# [WIP] Lua-ipfs
Ipfs API Lua module. Partialy implemented.

You need a running ipfs daemon. Currently, tested with the Go implementation of ipfs.


## Install

```luarocks install luaipfs``` [wip]

Or compile it yourself. Libcurl (C library), luajson and luafilesystem modules are needed.



## Usage

Create a new ipfs object:
```
local luaipfs = require("luaipfs")

local ipfs = luaipfs:new()
```

And use it to download a file from ifps:
```
local file = io.open("dot.gif", "w+")
file:write(
   ipfs:cat("/ipfs/QmbwqqE78Xba5z8j3CiaAMfPxjSNSda9Z9Rc5VhjyhLkt1")
)
file:close()
```

Of course, you can do a lot more. Read the documentation.


## Documentation

See *doc/luaipfs.md* for a list of available functions.

Or ```luarocks doc luaipfs```.

Some useful informations can be found on the ipfs website.
The API reference is here: https://ipfs.io/docs/api/.


De la doc en français est également disponible à cette adresse: https://wiki.gauf.re/p2p/lua-ipfs-api (wip)
