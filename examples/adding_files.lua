local lipfs = require("luaipfs")


local ipfs = lipfs:new()



--Adding directories and files recursively

local ret, err = ipfs:add("testdir", true)
if not ret then
   print(err)
   return 1
end

print("Name: ", ret.name)
print("Size: ", ret.size)
print("Hash: ", ret.hash)





return 0
