--[[ 
   Copyright © 2018 Neph <neph@crypt.lol>
   This program is free software. It comes without any warranty, to
   the extent permitted by applicable law. You can redistribute it
   and/or modify it under the terms of the Do What The Fuck You Want
   To Public License, Version 2, as published by Sam Hocevar. 
   See the LICENSE file for more details.
]]

local utils = require("luaipfs.utils")

local bitswap = {}


local is_json = utils.is_json




--https://github.com/ipfs/go-ipfs/blob/master/exchange/bitswap/decision/ledger.go

function bitswap:bitswap_ledger (nodeid)
   if not nodeid or type(nodeid) ~= "string" then
      return false, "Invalid parameter #1 (string expected, got " .. type(nodeid) .. ")"
   end

   local res, http_ret, err = self.http:post("/api/v0/bitswap/ledger?arg=" .. nodeid)
   if not res then
      if err and not is_json(err) then return false, err end
      return false, err and (json.decode(err)).Message or http_ret
   end

   
   res = json.decode(res)
   local final_res = {}
   for k, v in pairs(res) do
      final_res[string.lower(k)] = v
   end

   return final_res
end



return bitswap
