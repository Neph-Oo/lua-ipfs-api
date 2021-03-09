

-- See https://github.com/ipfs/go-ipfs/blob/1e9e2f453c435272433a96ebfba5c4319cc08534/namesys/pb/namesys.proto

local ipns_entry = [[
   message IpnsEntry {
      enum ValidityType {
         EOL = 0;
      }
      required bytes value = 1;
      required bytes signature = 2;

      optional ValidityType validityType = 3;
      optional bytes validity = 4;

      optional uint64 sequence = 5;

      optional uint64 ttl = 6;
   }
]]


local pb_schema = {
   ["ipns"] = {
      name = "IpnsEntry",
      data = ipns_entry
   }
}


return pb_schema