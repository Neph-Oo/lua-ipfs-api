local lipfs = require("luaipfs")


local ipfs = lipfs:new()





--Retrieve address (multiadress) for a given peer. Here, it's the id of one of the bootstrap node)

local peer_id = "QmNnooDu7bfjPFoTZYxMNLWUQJyrVwtbZg5gBMjTezGAJN"

local peer, err = ipfs:dht_findpeer(peer_id)
if not peer then
   print(err)
   return
end

for k, v in pairs(peer) do
   print(k, v)
end





--Searching in the DHT for the closest peers id to that peer id (my own id). 

local peer_id = "12D3KooWPUcG1ocRVb2ow26oq3DGTQkZjtPKXAHc3vYaJARpEhYc"

local ret, err = ipfs:dht_query(peer_id)
if not ret then
   print(err)
   return
end


for k, v in pairs(ret) do
   print(k, v)
end





--(Re)provide/announce to the DHT that we have a file corresponding to the given key (file should exist in ipfs db). 
--Key correspond to the ipfs documentation directory (pined by default with go-ipfs).

local key = "QmQPeNsJPyVWPFDVHb77w8G42Fvo15z4bG2X8D2GhfbSXc"

local ret, err = ipfs:dht_provide(key)
if not ret then
   print(err)
   return
end

print(ret)




return 0
