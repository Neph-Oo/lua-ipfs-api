--[[ 
   Copyright © 2018 Neph <neph@crypt.lol>
   This program is free software. It comes without any warranty, to
   the extent permitted by applicable law. You can redistribute it
   and/or modify it under the terms of the Do What The Fuck You Want
   To Public License, Version 2, as published by Sam Hocevar. 
   See the LICENSE file for more details.
]]

local utils = require("luaipfs.utils")

local swarm = {}



local is_json = utils.is_json




function swarm:swarm_peers (prot, latency)
   local prot = prot or false
   local latency = latency or false

   if prot and type(prot) ~= "boolean" then
      return false, "Invalid parameter #1 (boolean expected, got " .. type(prot) .. ")"
   elseif latency and type(latency) ~= "boolean" then
      return false, "Invalid parameter #1 (boolean expected, got " .. type(latency) .. ")"
   end


   local api_call = "/api/v0/swarm/peers?streams=" 
      .. tostring(prot) .. "&latency=" .. tostring(latency)
   

   local res, http_ret, err =  self.http:get(api_call)
   if not res then
      if err and not is_json(err) then return false, err end
      return false, err and (json.decode(err)).Message or http_ret
   end

   res = (json.decode(res)).Peers
   local peers = {}
   for _, v in pairs(res) do
      peers[#peers + 1] = {}
      peers[#peers]["address"] = v.Addr
      peers[#peers]["nodeid"] = v.Peer
      peers[#peers]["latency"] = (v.Latency ~= "") and v.Latency or nil
      peers[#peers]["protocol"] = 
         (type(v.Streams) == "table" and v.Streams[1]) and v.Streams[1].Protocol or nil
   end

   return peers
end


return swarm
