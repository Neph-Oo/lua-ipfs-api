
![IPFS http logo](https://user-images.githubusercontent.com/1211152/29604883-ca3a4028-87e0-11e7-9f9a-75de49b06048.png)

# [WIP] Lua-ipfs
Lua Ipfs http client library, partialy implemented.

You need go-ipfs running in the background for using this module. Currently, it has only been tested with the Go implementation of ipfs.


## Install

```luarocks install luaipfs``` [wip]

Or compile it yourself. You will need libcurl (C library), luajson and luafilesystem modules.



## Usage

Create a new ipfs object:
```
local luaipfs = require("luaipfs")

local ipfs = luaipfs:new()
```

And download a file from ifps:
```
local file = io.open("dot.gif", "w+")
file:write(
   ipfs:cat("/ipfs/QmbwqqE78Xba5z8j3CiaAMfPxjSNSda9Z9Rc5VhjyhLkt1")
)
file:close()
```


## Documentation

See *doc/luaipfs.md* for a list of available functions.

Or ```luarocks doc luaipfs```.

Some useful informations can be found on the ipfs website.
You can found official api reference here: https://ipfs.io/docs/api/.


