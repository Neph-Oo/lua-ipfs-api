--[[ 
   Copyright © 2018 Neph <neph@crypt.lol>
   This program is free software. It comes without any warranty, to
   the extent permitted by applicable law. You can redistribute it
   and/or modify it under the terms of the Do What The Fuck You Want
   To Public License, Version 2, as published by Sam Hocevar. 
   See the LICENSE file for more details.
]]

local utils = {}


function utils.is_json (data)
   if string.match(data, "{%s*\".+\"%s*:%s*\".+\"%s*,%s*\".+\"%s*:%s*\"*.+\"*%s*}") then
      return true
   end
   return false
end


return utils
