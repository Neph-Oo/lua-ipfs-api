local lanes = (require("lanes")).configure()


f1 = lanes.gen("*", function ()
   local lipfs = require("luaipfs")

   local ipfs = lipfs:new()
   local peers = ipfs:swarm_peers()
   if not peers then return false end

   for k, v in pairs(peers) do
      if k >= #peers - 5 then
         print("--------Peer ", k)
         print(v.nodeid)
         print(v.address)
         os.execute("sleep 1")
      end
   end
   return true
end)

f2 = lanes.gen("*", function ()
   local lipfs = require("luaipfs")

   local ipfs = lipfs:new()
   local peer_id = "QmNnooDu7bfjPFoTZYxMNLWUQJyrVwtbZg5gBMjTezGAJN"

   local peer, err = ipfs:dht_findpeer(peer_id)
   if not peer then
      print(err)
      return false
   end
   for k, v in pairs(peer) do
      print(k, v)
   end
   return true
end)


f3 = lanes.gen("*", function ()
   local lipfs = require("luaipfs")

   local ipfs = lipfs:new()

   local key = "/ipns/k51qzi5uqu5dl8ovmsw032wd9manqo8asfwdw3m6e84qyng2qbspv97dap5bpd"
   local data, err = ipfs:dht_get(key, "b64")
   if not data then 
      print(err)
      return false
   end

   print(data)   
   return true
end)


t1 = f1()
t2 = f2()
t3 = f3()

print(t1[1], t2[1], t3[1])
