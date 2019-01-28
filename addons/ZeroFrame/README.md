# ZeroFrame Godot Plugin

This plugin seeks to be a 1:1 compatible client for the ZeroNet [ZeroFrame
WebSocket
API](https://zeronet.io/docs/site_development/zeroframe_api_reference/) for
Godot! What does that mean? It means you can interface and interact with the
[ZeroNet Network](https://zeronet.io) from your Godot game. Everything from
storing player content to match-making to social networking features all on a
completely p2p and trustless infastructure. Have your players host your data
for you, for free!

## Installation

There are two methods for installing the plugin.

**Asset Store [Coming Soon]:**

Go to the 'AssetLib' tab in Godot and search for 'ZeroFrame'. You should find the ZeroFrame plugin. Select it and hit download.

**Manual:**

[Download](https://github.com/anoadragon453/godot-zeroframe-plugin/releases)
this repository, rename it to `ZeroFrame` and copy it to your game's `addons/`
directory (create it if it doesn't exist).

---

No matter which method you choose, after installation you'll want to go to Godot's Menu and select Project > Project Settings. Select the Plugins tab, and here you should see 'ZeroFrame' as a downloaded plugin. Make sure to activate it.

Next, head to the 'AutoLoad' tab and click the small folder icon next to the path field. Browse to `addons/ZeroFrame/ZeroFrame.gd` and select it. This will AutoLoad the ZeroFrame plugin and all you to use the `ZeroFrame` variable in your scripts.

Finally, the ZeroFrame plugin will not work without a running ZeroNet instance. We understand that it would be a pain to ask all of your users to install ZeroNet just to play your game. Thus, we ~~have made~~ have a ZeroNet plugin in the works as well, which will start up a self-contained copy of ZeroNet that can be bundled with your game. Look out for this soonish!

## Usage

If you've set your AutoLoad up correctly, then you should have a `ZeroFrame` variable available to you in every script. The methods for which are documented below:

### `cmd(command_id: string, parameters: dictionary)`

`cmd` is the method that ZeroFrame relies on. It takes requests from Godot, sends them over a WebSocket connection to a running ZeroNet process, and returns the result.

`cmd` follows the [ZeroFrame API](https://github.com/anoadragon453/godot-zeroframe-plugin/releases), with command IDs and parameters being exactly the same. For instance, if you'd like to store some data on the currently connected ZeroNet site:

```python
# Store some data on the site
# auth_address is effectively a player's user ID
var inner_path = "data/%s/data.json" % site_info["auth_address"]

# Our player's score
var score = {"score": 500}

# ZeroNet expects data as base64, so convert it to that format
var data = Marshalls.utf8_to_base64(JSON.print(score))

# Make a `fileWrite` request to ZeroNet. Store the file at `inner_path`, with the contents `data`
# `yield` blocks until storage is complete
var response = yield(ZeroFrame.cmd("fileWrite", {"inner_path": inner_path, "content_base64": data}), "command_completed")

# Check the response. If "ok", then it was successful
print("Store response: ", response)
if response == "ok":
    print("File successfully stored at '%s'!" % inner_path)

# Publish our changes to peers
response = yield(ZeroFrame.cmd("sitePublish", {"sign": true}), "command_completed")
```

```
Store response: ok
File successfully stored at 'data/someaddress/data.json'!
```

And then retrieving that data later, or from another player's computer:

```python
# Retrieve data using the `fileGet` command. Same `inner_path`
response = yield(ZeroFrame.cmd("fileGet", {"inner_path": inner_path}), "command_completed")

# Score was stored as JSON, parse JSON back to Godot dictionary
var user_data = JSON.parse(response.result)

# Print the result
print(user_data.result)
```

```javascript
{"score": 500}
```

And that's all! The player data is now stored on the network and the player can shutdown their computer without having to worry about losing their data.

### `use_site(site_address: string)` 

Before you can start issuing any `cmd`s however, you'll need to connect to a ZeroNet site first. Every ZeroNet site has an address, something akin to `1HeLLo4uzjaLetFx6NH3PMwFP3qbRbTf3D`, which is the default ZeroNet site if you're actually using ZeroNet in the browser. Now you can't just go around storing your game data on any old site. If you don't have your own yet, read [Creating a New ZeroNet site](https://zeronet.io/docs/using_zeronet/create_new_site/) to get one!

Connecting to a ZeroNet site is fairly simple:

```python
# My own little site address
var site_address = "1vcpDyMSZWDMmsD81Z6zApFStPvr2j728"

# Open a connection to a ZeroNet site
if not yield(ZeroFrame.use_site(site_address), "site_connected"):
    print("Unable to connect to site")
    return
print("Connected to %s." % site_address)
```

```
Connected to 1vcpDyMSZWDMmsD81Z6zApFStPvr2j728.
```

After this you'll be able to execute any ol' `cmd()` you like.

### `set_daemon(host: string, port: int)`

Allows you to configure a custom `host` address and `port` number for the ZeroNet proxy. The default values are `127.0.0.1` for host and `43110` for port, as those are the standard ZeroNet values.

```python
# Connect to a custom ZeroNet instance
ZeroFrame.set_daemon("192.168.1.15", 43110)
```

This can also be done using the ZeroFrame panel in Godot's UI.
