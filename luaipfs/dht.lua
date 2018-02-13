--[[ 
   Copyright © 2018 Neph <neph@crypt.lol>
   This program is free software. It comes without any warranty, to
   the extent permitted by applicable law. You can redistribute it
   and/or modify it under the terms of the Do What The Fuck You Want
   To Public License, Version 2, as published by Sam Hocevar. 
   See the LICENSE file for more details.
]]

local utils = require("luaipfs.utils")

local dht = {}


local is_json = utils.is_json






--Dht functions, see list of response type in go-ipfs impl
--https://github.com/libp2p/go-libp2p-routing/blob/master/notifications/query.go
--[[
   type 1: PeerResponse
   type 2: FinalPeer
   type 3: QueryError
   type 4: Provider
   type 5: Value
   type 6: AddingPeer
   type 7: DialingPeer

]]

function dht:dht_findpeer (nodeid)
   if not nodeid or type(nodeid) ~= "string" then
      return false, "Invalid parameter #1 (string expected, got " .. type(nodeid) .. ")"
   end

   local res, http_ret, err = self.http:get("/api/v0/dht/findpeer?arg=" .. nodeid)
   if not res then
      if err and not is_json(err) then return false, err end
      return false, err and (json.decode(err)).Message or http_ret
   end


   --Parse each line from answer
   
   local t = {}
   for line in string.gmatch(res, "[^\n]+") do
      t[#t + 1] = json.decode(line)
   end

   --Retrieve peer multiaddrs
   
   local err
   local multiaddrs = {}
   for _, v in pairs(t) do
      if type(v) == "table" and v.Type == 2 and v.Responses[1].ID == nodeid then
         for k1, v1 in pairs(v.Responses[1].Addrs) do
            multiaddrs[k1] = v1
         end
      elseif type(v) == "table" and v.Type == 3 then
         err = v.Extra or nil
      end
   end

   if err and #multiaddrs < 1 then
      return false, err
   end

   return multiaddrs
end





function dht:dht_findprovs (key)
   if not key or type(key) ~= "string" then
      return false, "Invalid parameter #1 (string expected, got " .. type(key) .. ")"
   end

   local res, http_ret, err = self.http:get("/api/v0/dht/findprovs?arg=" .. key)
   if not res then
      if err and not is_json(err) then return false, err end
      return false, err and (json.decode(err)).Message or http_ret
   end


   --Parse each line from answer

   local t = {}
   for line in string.gmatch(res, "[^\n]+") do
      t[#t + 1] = json.decode(line)
   end


   --Filter peers who can provide searched value

   local peers = {}
   for _, v in pairs(t) do
      if type(v) == "table" and v.Type == 4 then
         peers[#peers + 1] = v.Responses[1].ID
      end
   end


   return peers
end




function dht:dht_get (key)
   if not key or type(key) ~= "string" then
      return false, "Invalid parameter #1 (string expected, got " .. type(key) .. ")"
   end

   local res, http_ret, err = self.http:get("/api/v0/dht/get?arg=" .. key)
   if not res then
      if err and not is_json(err) then return false, err end
      return false, err and (json.decode(err)).Message or http_ret
   end

   --Parse each line from answer

   local t = {}
   for line in string.gmatch(res, "[^\n]+") do
      t[#t + 1] = json.decode(line)
   end

   
   --Will return type 5 (value) if it find one in the dht

   local value = nil
   for k, v in pairs(t) do
      if type(v) == "table" and v.Type == 5 then
         value = v.Extra
      end
   end

   if not value then return false, "no value found in dht" end
   return value
end



--Note, https://github.com/ipfs/go-ipfs/blob/master/namesys/pb/namesys.proto

function dht:dht_put (key, value)
   if not key or type(key) ~= "string" then
      return false, "Invalid parameter #1 (string expected, got " .. type(key) .. ")"
   elseif not value or type(value) ~= "string" then
      return false, "Invalid parameter #2 (string expected, got " .. type(value) .. ")"
   end

   local res, http_ret, err = self.http:get("/api/v0/dht/put?arg=" .. key .. "&arg=" .. value)
   if not res then
      if err and not is_json(err) then return false, err end
      return false, err and (json.decode(err)).Message or http_ret
   end

   print(res)

   --Parse each line from answer

   local t = {}
   for line in string.gmatch(res, "[^\n]+") do
      t[#t + 1] = json.decode(line)
   end
   
   local value = {}
   for k, v in pairs(t) do
      if type(v) == "table" and v.Type == 5 then
         value[#value +1] = v.ID
      end
   end
      
   return (#value > 0) and value or false, "can't put value in dht"
end





function dht:dht_query (node_id)
   if not node_id or type(node_id) ~= "string" then
      return false, "Invalid parameter #1 (string expected, got " .. type(node_id) .. ")"
   end

   local res, http_ret, err = self.http:get("/api/v0/dht/query?arg=" .. node_id)
   if not res then
      if err and not is_json(err) then return false, err end
      return false, err and (json.decode(err)).Message or http_ret
   end


   --Parse each line from answer

   local t = {}
   for line in string.gmatch(res, "[^\n]+") do
      t[#t + 1] = json.decode(line)
   end

   local peers = {}
   for k, v in pairs(t) do
      if type(v) == "table" and (v.Type == 2 or v.Type == 6) then
         peers[#peers + 1] = v.ID
      end
   end

   return (#peers > 0) and peers or false, "no peers found"
end





function dht:dht_provide (key)
   if not key or type(key) ~= "string" then
      return false, "Invalid parameter #1 (string expected, got " .. type(key) .. ")"
   end

   local res, http_ret, err = self.http:get("/api/v0/dht/provide?arg=" .. key)
   if not res then
      if err and not is_json(err) then return false, err end
      return false, err and (json.decode(err)).Message or http_ret
   end

   return true
end





return dht
