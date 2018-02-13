local lipfs = require("luaipfs")


local ipfs = lipfs:new()


local peer_id = "QmPNsW7U8bPBPG9axukhuL5QMJHkhjHYRj1dpRrzTYWfnd"

local peer, err = ipfs:dht_findpeer(peer_id)
if not peer then
   print(err)
   return
end

for k, v in pairs(peer) do
   print(k, v)
end




local id = "QmPNsW7U8bPBPG9axukhuL5QMJHkhjHYRj1dpRrzTYWfnd"

local ret, err = ipfs:dht_query(id)
if not ret then
   print(err)
   return
end


for k, v in pairs(ret) do
   print(k, v)
end


--[[
local key = "QmTopSaqr1Qzxbni1dywwADyovtjKi3KSUstzxzkkbczvm"

local ret, err = ipfs:dht_provide(key)
if not ret then
   print(err)
   return
end
]]

return 0
