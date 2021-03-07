--[[ 
   Copyright © 2018 Neph <neph@crypt.lol>
   This program is free software. It comes without any warranty, to
   the extent permitted by applicable law. You can redistribute it
   and/or modify it under the terms of the Do What The Fuck You Want
   To Public License, Version 2, as published by Sam Hocevar. 
   See the LICENSE file for more details.
]]

local utils = require("luaipfs.utils")

local pin = {}

local is_json = utils.is_json




function pin:pin_rm (ipfs_path)
   if not ipfs_path or type(ipfs_path) ~= "string" then
      return false, "Invalid parameter #1 (string expected, got " .. type(ipfs_path) .. ")"
   end

   local res, http_ret, err =  self.http:post("/api/v0/pin/rm?arg=" .. ipfs_path)
   if not res then
      if err and not is_json(err) then return false, err end
      return false, err and (json.decode(err)).Message or http_ret
   end

   return json.decode(res).Pins
end


return pin
