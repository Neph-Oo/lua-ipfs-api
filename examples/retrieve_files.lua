local lipfs = require("luaipfs")


local ipfs = lipfs:new()





--Retrieve a file in data buffer

local file = io.open("quick-start", "w+")
local data, err = 
   ipfs:cat("/ipfs/QmQPeNsJPyVWPFDVHb77w8G42Fvo15z4bG2X8D2GhfbSXc/quick-start")
if err then print(err) elseif file then file:write(data) end

file:close()







--Retrieve a file to path "help"

local ret, err = 
   ipfs:cat("/ipfs/QmQPeNsJPyVWPFDVHb77w8G42Fvo15z4bG2X8D2GhfbSXc/help", "help")
if err then print(err) end







--Retrieve an archive (file.s or directories) to path

local ret, err =
   ipfs:get("/ipfs/QmQPeNsJPyVWPFDVHb77w8G42Fvo15z4bG2X8D2GhfbSXc", "myarchive.tar")
if err then print(err) end






--An example using the adv_* call for retrieving a file.
--Set a callback function cb_func that will be call many times (until there is no more data) 
--during adv_cat function call.

local file = io.open("quick-start-copy", "w+")
local curr_size = 0
local function cb_func (ipfs_path, data, filesize)
   curr_size = curr_size + #data
   local percent = (curr_size * 100) / filesize
   io.stdout:write(string.format("Downloading %s: %d%%\n", ipfs_path, math.floor(percent)))
   file:write(data)
end



local ret, err = 
   ipfs:adv_cat("/ipfs/QmQPeNsJPyVWPFDVHb77w8G42Fvo15z4bG2X8D2GhfbSXc/quick-start", cb_func)
if not ret then print(err) end

file:close()


return 0
