local lipfs = require("luaipfs")


local ipfs = lipfs:new()



--Search in our buckets peers that's have exchanged data with us
--It we find some of them here, print others informations about that exchange

local peers = ipfs:swarm_peers()

for k, v in pairs(peers) do
   if v.nodeid then
      local ret, err = ipfs:bitswap_ledger(v.nodeid)
      if err then 
         print(err)
         return 1
      end

      local exchanged = tonumber(ret.exchanged)
      if exchanged > 0 then
         print("--------", "Peer " .. tostring(k) .. "  ", "-----------")
         for k1, v1 in pairs(ret) do
            print(k1, v1)
         end
      end
   end
end



return 0
