local lipfs = require("luaipfs")


local ipfs = lipfs:new()



--(Re)provide/announce to the DHT that we have a file corresponding to the given key (file should exist in ipfs db). 
--Key correspond to the ipfs documentation directory (pined by default with go-ipfs).

--[[
local key = "QmQPeNsJPyVWPFDVHb77w8G42Fvo15z4bG2X8D2GhfbSXc"

local ret, err = ipfs:dht_provide(key)
if not ret then
   print(err)
   return
end

print(ret)
]]


--Retrieve raw value (IPNS record / protobuf) from the dht and write it to a file 

local key = "/ipns/k51qzi5uqu5dl8ovmsw032wd9manqo8asfwdw3m6e84qyng2qbspv97dap5bpd"
local f = io.open("protobuf.pb", "wb")
if not f then return end

local ret, err = ipfs:dht_get(key)
if not ret then
   print(err)
   return
end

f:write(ret)
f:close()


return 0
