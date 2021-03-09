
## Comments
Due to Lua language and because this module don't use non-blocking functions, it's not possible to use the following api without blocking and ipfs (more precisely, exploring a dht) can take **a lot of time** before returning results.    
For that reason, I recommend to use C and create Lua states for running luaipfs instances in different threads. You can also use [Lanes](https://lualanes.github.io/lanes/) who will handle that for you.  

I've added some functions for downloading big files without taking a lot of memory. Search for functions like *adv_xxx()*. You can register a function callback that will be called when new data are available.     




## Functions list

___
#### ipfs:new(opt)
*Create new ipfs object.*

###### Args:
> opt (optional, table) : ipfs instance options. You can use timeout to set a limit (in seconds) for each api call.

```lua
opt = {
   server = "localhost",
   port = 5001,
   timeout = 120
}
```

###### Return:
> A new ipfs object.


___
#### ipfs:add(filepath, recursive, pin)
   *Add a file (or directory) to ipfs*

###### Args:
> filepath (string) : path to file/directory  
recursive (optional, boolean) : add files recursively (default to false)  
pin (optional, boolean) : pin file (default to true)  

###### Return:
> A lua table containing filename, size and hash (ipfs object) of uploaded file:  

```lua
ret = {
   filename = "string",
   size = "string",
   hash = "string"
}
```
> Or false and an error message.  


___
#### ipfs:bitswap\_ledger (node_id)
*Return bitswap ledger from peer (node_id)*

###### Args:
> node_id (string) : node id of peer

###### Return:
> A lua table contaning peer (short) id, data sent, data received, number of exchange and ledger value (debt ratio with that peer)

```lua
ret = {
   peer = "string",
   exchanged = number,
   sent = number,
   recv = number,
   value = number
}
```

> Or false and an error message.




___
#### ipfs:cat(ipfs_path, filepath)
*Retrieve an individual file*

###### Args:
> ipfs_path (string) : Ipfs path  
> filepath (optional, string) : Path for saving file


###### Return:
> Function will return a buffer filed with file data unless filepath is set.
If filepath is set, function will return true and write data to filepath.

> Or false and an error message.  




___
#### ipfs:adv_cat(ipfs_path, callback)
*Register a callback function for retrieving an individual file.*

###### Args:
> ipfs_path (string) : Ipfs path

> callback (function) : A callback function, see the following definition.  

```lua
function callback (ipfs_path, data_chunk, datasize)
```

> Where ipfs_path is the argument you have passed to adv_cat, data_chunk a part of the file, and datasize the expected final size of file. 

###### Return:
> True.  

> Or false and an error message.  

 



___
#### ipfs:dht\_findpeer(node_id)
*Search for a peer in the dht*

###### Args:
> node_id (string) : node/peer id to search for

###### Return:
> A list containing each known ipfs multiaddress of peer.
      
> Or false and an error.



___
#### ipfs:dht_findprovs(key)
*Search for peers (nodeid) who can provide data for the requested key*

###### Args:
> key (string) : key (multihash) to search for

###### Return:
> A list (default to 20) of peers (nodeid) who can provide requested object.

> Or false and an error.



___
#### ipfs:dht_provide(key)
*Announce to the dht we can provide data corresponding to key (register/refresh entry for key).*

###### Args:
> key (string) : key (multihash) to provide

###### Return:

> True.

> Or false and an error.



___
#### ipfs:dht_get(key, mode)
*Retrieve a value from the dht if a corresponding key exist.*  

*Warn : use this command only if you know what you're doing. Result can vary between implementation. For example, in go-ipfs, key is in the form /keytype/keyname(multihash) where keytype can only be /ipns. In IPNS context, dht_get will return a valid IPNS record (protobuf) which is valid and has the highest sequence number. If you really want to use this, look at dht_advanced.lua in example directory.*
  

###### Args:
> key (string) : key (multihash) to search for
> mode (optional, string) : mode can be "lua", "raw" (protobuf) or "b64" (base64). Default to "raw".  

###### Return:
> Arbitrary data value (IPNS record for /ipns in lua, raw or b64 encoding).

```lua
--For "lua" mode :
ret = {
   signature = "bin-string",
   validityType = "string",
   sequence = "number",
   validity = "string",
   value = "string"
}
```

> Or false and an error.




___
#### ipfs:dht_put(key, value)
*Set a key/value in the dht.*

*Warn: use this command only if you know what you're doing. Result can vary between implementation. For example, in go-ipfs, key is in the form /keytype/keyname(multihash) where keytype can only be /ipns. Keyname should correspond to a peer id (multihash of a user's public key) and data should be an IPNS record (protobuf) signed with the user's private key. If you really want to use this, look at dht_advanced.lua in example directory.*

###### Args:
> key (string) : peer id (or another user's public key hash) 
> value (string) : IPNS record (protobuf .pb filepath)

###### Return:
> A list of peers/neighbors (node id) where we have store value in the dht. 
> *(I'm not sure what "type 5" is in that case, so I have guess it.. if you know that statement is false, tell me).*

> Or false and an error.



___
#### ipfs:dht_query(node_id)
*Search for peers in the dht. Somehow like findpeer but node_id doesn't have to exist. It will return a list of closest peers of node_id (xor routing).*

###### Args:
> node_id (string) : node id to search for

###### Return:
> A list of peers (node id).

> Or false and an error.





___
#### ipfs:get(ipfs_path, filepath)
*Retrieve an archive of file.s/directories*

###### Args:
> ipfs_path (string) : Ipfs path  
> filepath (optional, string) : Path for saving file


###### Return:
> A buffer filed with file (archive) data unless filepath is set.  
If filepath is set, function will return true and write data to filepath.

> Or false and an error message.




___
#### ipfs:adv_get(ipfs_path, callback)
*Register a callback function for retrieving an archive of file.s/directories*

###### Args:
> ipfs_path (string) : Ipfs path   
> callback (function) : A callback function, see the following definition.  

```lua
function callback (ipfs_path, data_chunk, datasize)
```

> Where ipfs_path is the argument you have passed to adv_get, data_chunk a part of the archive, and datasize the expected final size of archive.  


###### Return:
> True.  

> Or false and an error message.  




___
#### ipfs:id(node_id)
*Retrieve ipfs node id infos*

###### Args:
> node_id (string, optional) : node id

###### Return:
> A table containing id, agentversion, protocolversion, publickey and addresses (list) of peer. If node_id is nil, function will return our own id's infos.

```lua
ret = {
   id = "string",
   agentversion = "string",
   publickey = "string",
   protocolversion = "string",
   addresses = {
      [1] = "string",
      [2] = "string",
      [3] = ...
   }
}
```

> Or false and an error message.




___
#### ipfs:ls (ipfs_path)
*List directory contents (unix file objects)*

###### Args:
> ipfs_path (string) : Ipfs path (multihash) of file/directory

###### Return:
> A table of files containing file info.   

```lua
ret = {
   [1] = {
      name = "string",
      hash = "string",
      size = number,
      type = "string"
   },
   [2] = ...
}
```



___
#### ipfs:pin\_rm(ipfs_path)
*Remove a pinned file from local repository*

###### Args:
> ipfs_path (string) : Ipfs path

###### Return:
> A list containing pins removed.




___
#### ipfs:swarm_peers(prot, latency)
*Return list of known/connected peers*

###### Args:
> prot (optional, boolean) : retrieve protocol used by peer, default to false  
> latency (optional, boolean) : retrieve latency, default to false


###### Return:
> A list of tables representing connected peers. Default entries are node id and ipfs multiaddress for that peer.  
If prot is set, each peer table will also have an entry for protocol in use.  
If latency is set, each peer table will also have an entry for latency (can be 'n/a').

```lua
ret = {
   {
      address = "string",
      nodeid = "string",
      prot = "string, optional",
      latency = "string, optional"
   },
   {
      ...
   },
   ...
}
```

> Or false and an error message.


