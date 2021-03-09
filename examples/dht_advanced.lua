local lipfs = require("luaipfs")


local ipfs = lipfs:new()



--Retrieve raw value of IPNS record (protobuf binary format) from the dht and write it to a file 

local key = "/ipns/k51qzi5uqu5dl8ovmsw032wd9manqo8asfwdw3m6e84qyng2qbspv97dap5bpd"
local f = io.open("ipns_record.pb", "w+b")
if not f then return end

print("Trying to write ipns_record.pb ...")
local ret, err = ipfs:dht_get(key)
if not ret then
   print(err)
   return
end

f:write(ret)
f:close()
print("Sucess !")




--[[
   Retrieve and convert IPNS record (protobuf) to Lua table, print some informations
   from IPNS record and try to list files from ipfs link. 
]]

local key = "/ipns/k51qzi5uqu5dl8ovmsw032wd9manqo8asfwdw3m6e84qyng2qbspv97dap5bpd"
local ret, err = ipfs:dht_get(key, "lua")
if not ret then
   print(err)
   return
end

print("IPNS record is valid until : " .. ret.validity)
print("IPFS link attached to it : " .. ret.value)

local files = ipfs:ls(ret.value)
for i, file in pairs(files) do
   print("---File #" .. i)
   for k, v in pairs(file) do
      print(k, v)
   end
end




--[[
   Put key/value on the dht using ipns (user's id/public key) as key and previously saved ipns_record.pb as value.
   It will update/replace old IPNS record and return the list of peers who received the new record (I think). 
]]

local key = "/ipns/k51qzi5uqu5dl8ovmsw032wd9manqo8asfwdw3m6e84qyng2qbspv97dap5bpd"

print("Trying to put " .. key .. " and ipns_record.pb in the dht ...")

local ret, err = ipfs:dht_put(key, "ipns_record.pb")
if not ret then 
   print(err)
   return
end

print("List of peers who received new IPNS record :")
for k, v in pairs(ret) do
   print(k, v)
end



return 0
