--[[ 
   Copyright © 2018 Neph <neph@crypt.lol>
   This program is free software. It comes without any warranty, to
   the extent permitted by applicable law. You can redistribute it
   and/or modify it under the terms of the Do What The Fuck You Want
   To Public License, Version 2, as published by Sam Hocevar. 
   See the LICENSE file for more details.
]]


local utils = require("luaipfs.utils")

local base = {}




--[[ Private module functions ]]--


local function add_dir (tfiles, path, filename)
   for file in lfs.dir(path) do
      if file == "." or file == ".." then goto continue end

      --Retrieve file type, skip it if it's not a valid type

      local fattr, err = lfs.attributes(path .. "/" .. file)
      if not fattr or (fattr.mode ~= "directory" and fattr.mode ~= "file") then 
         goto continue 
      end


      tfiles[#tfiles + 1] = {} 
      tfiles[#tfiles].path = path .. "/" .. file
      tfiles[#tfiles].filename = filename .. "/" .. file
      tfiles[#tfiles].mode = fattr.mode


      if fattr.mode == "directory" then
         add_dir(tfiles, tfiles[#tfiles].path, tfiles[#tfiles].filename)
      end

      ::continue::
   end
end

local is_json = utils.is_json







--[[ Public module functions ]]--



function base:get (ipfs_path, out_path)
   if not ipfs_path or type(ipfs_path) ~= "string" then
      return false, "Invalid parameter #1 (string expected, got " .. type(ipfs_path) .. ")"
   end
   if out_path and type(out_path) ~= "string" then
      return false, "Invalid parameter #2 (string expected, got " .. type(out_path) .. ")"
   end


   local res, http_ret, err = self.http:get("/api/v0/get?arg=" .. ipfs_path, out_path)
   if not res then
      if err and not is_json(err) then return false, err end
      return false, err and (json.decode(err)).Message or http_ret
   end

   return res
end



function base:adv_get (ipfs_path, cb_func)
   if not ipfs_path or type(ipfs_path) ~= "string" then
      return false, "Invalid parameter #1 (string expected, got " .. type(ipfs_path) .. ")"
   elseif not cb_func or type(cb_func) ~= "function" then
      return false, "Invalid parameter #1 (function expected, got " .. type(cb_func) .. ")"
   end

   local res, http_ret, err = self.http:get_cb("/api/v0/get?arg=" .. ipfs_path, ipfs_path, cb_func)
   if not res then
      if err and not is_json(err) then return false, err end
      return false, err and (json.decode(err)).Message or http_ret
   end

   return res
end





function base:cat (ipfs_path, out_path)
   if not ipfs_path or type(ipfs_path) ~= "string" then
      return false, "Invalid parameter #1 (string expected, got " .. type(ipfs_path) .. ")"
   end
   if out_path and type(out_path) ~= "string" then
      return false, "Invalid parameter #2 (string expected, got " .. type(out_path) .. ")"
   end


   local res, http_ret, err = self.http:get("/api/v0/cat?arg=" .. ipfs_path, out_path)
   if not res then
      if err and not is_json(err) then return false, err end
      return false, err and (json.decode(err)).Message or http_ret
   end

   return res
end



function base:adv_cat (ipfs_path, cb_func)
   if not ipfs_path or type(ipfs_path) ~= "string" then
      return false, "Invalid parameter #1 (string expected, got " .. type(ipfs_path) .. ")"
   elseif not cb_func or type(cb_func) ~= "function" then
      return false, "Invalid parameter #1 (function expected, got " .. type(cb_func) .. ")"
   end

   local res, http_ret, err = self.http:get_cb("/api/v0/cat?arg=" .. ipfs_path, ipfs_path, cb_func)
   if not res then
      if err and not is_json(err) then return false, err end
      return false, err and (json.decode(err)).Message or http_ret
   end

   return res
end




function base:add (filepath, recursive, pin)
   local recursive = recursive or false

   --Verify function args

   if not filepath or type(filepath) ~= "string" then
      return false, "Invalid parameter #1 (string expected, got " .. type(filepath) .. ")"
   elseif recursive and type(recursive) ~= "boolean" then
      return false, "Invalid parameter #2 (boolean expected, got " .. type(recursive) .. ")"
   elseif pin and type(pin) ~= "boolean" then
      return false, "Invalid parameter #3 (boolean expected, got " .. type(pin) .. ")"
   elseif not pin and pin ~= false then
      pin = true
   end


   local fattr, err = lfs.attributes(filepath)
   if not fattr then return false, err end

   if recursive and fattr.mode ~= "directory" then
      return false, "Invalid parameter for recursive call (directory expected, got " 
         .. fattr.mode .. ")"
   elseif fattr.mode ~= "directory" and fattr.mode ~= "file" then
      return false, "Invalid parameter (file or directory expected, got "
         .. fattr.mode .. ")"
   end



   --Prepare files list before calling post_multipart_data

   local filename = string.gsub(filepath, ".+/", "")
   local tfiles = {}
   tfiles[1] = {}
   tfiles[1].filename = filename
   tfiles[1].path = filepath
   tfiles[1].mode = fattr.mode
   if recursive then
      add_dir(tfiles, filepath, filename)
   end


   local api_call = "/api/v0/add?recursive=" .. tostring(recursive) .. "&pin=" .. tostring(pin) 
   local res, http_ret = self.http:post_multipart_data(api_call, tfiles)
   if not res then
      return false, http_ret
   end

   res = json.decode(res)
   local final_res = {}
   for k, v in pairs(res) do
      final_res[string.lower(k)] = v
   end 

   return final_res
end




function base:ls (ipfs_path)
   local ftype = {
      "directory",
      "file"
   }

   if not ipfs_path or type(ipfs_path) ~= "string" then
      return false, "Invalid parameter #1 (string expected, got " .. type(ipfs_path) .. ")"
   end

   local res, http_ret, err = self.http:get("/api/v0/ls?arg=" .. ipfs_path)
   if not res then
      if err and not is_json(err) then return false, err end
      return false, err and (json.decode(err)).Message or http_ret
   end


   local flist = {}
   local obj = (json.decode(res)).Objects
   for _, t in pairs(obj[1].Links) do
      flist[#flist + 1] = {}
      flist[#flist].type = ftype[t.Type]
      flist[#flist].name = t.Name
      flist[#flist].hash = t.Hash
      flist[#flist].size = t.Size
   end

   return flist
end




function base:id (node_id)
   if node_id and type(node_id) ~= "string" then
      return false, "Invalid parameter #1 (string expected, got " .. type(node_id) .. ")"
   end

   local req = node_id and ("/api/v0/id?arg=" .. node_id) or "/api/v0/id"

   local res, http_ret, err = self.http:get(req)
   if not res then
      if err and not is_json(err) then return false, err end
      return false, err and (json.decode(err)).Message or http_ret
   end

   local id = {}
   res = json.decode(res)
   for k, v in pairs(res) do   
      if k == "Addresses" then
         id[string.lower(k)] = {}
         for k1, v1 in pairs(v) do
            id[string.lower(k)][k1] = v1
         end
      else
         id[string.lower(k)] = v
      end
   end

   return id
end



return base
