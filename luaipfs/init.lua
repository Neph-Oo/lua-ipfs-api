--[[
   Copyright © 2018 Neph <neph@crypt.lol>
   This program is free software. It comes without any warranty, to
   the extent permitted by applicable law. You can redistribute it
   and/or modify it under the terms of the Do What The Fuck You Want
   To Public License, Version 2, as published by Sam Hocevar. 
   See the LICENSE file for more details.
]]


local http = require("luaipfs.http")
local json = require("json")
local lfs = require("lfs")
local base = require("luaipfs.base")
local bitswap = require("luaipfs.bitswap")
local dht = require("luaipfs.dht")
local pin = require("luaipfs.pin")
local swarm = require("luaipfs.swarm")




local ipfs = {
   cat = base.cat,
   adv_cat = base.adv_cat,
   get = base.get,
   adv_get = base.adv_get,
   add = base.add,
   ls = base.ls,
   id = base.id,
   swarm_peers = swarm.swarm_peers,
   pin_rm = pin.pin_rm,
   dht_findpeer = dht.dht_findpeer,
   dht_findprovs = dht.dht_findprovs,
   dht_get = dht.dht_get,
   dht_put = dht.dht_put,
   dht_query = dht.dht_query,
   dht_provide = dht.dht_provide,
   bitswap_ledger = bitswap.bitswap_ledger,
}




--[[ Public module functions ]]--


--Module factory

function ipfs:new (o)

   --Instanciate new ipfs object

   local o = o or {}
   self.__index = self
   setmetatable(o, self)


   --Attach new http to it

   o.http = http:new({server = o.server, port = o.port, timeout = o.timeout})


   return o
end



return ipfs
