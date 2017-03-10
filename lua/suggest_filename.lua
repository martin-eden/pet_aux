-- Extracts download link and gives a neat file name for given JSON file
-- for server.

--[[
  Status: done
  Last mod.: 2016-03-22
  Notes:

    Usage: <json_auction_link>

    <json_auction_link> sample contents:

    {
      "files": [
        {
          "url": "http://auction-api-eu.worldofwarcraft.com/auction-data/b6a53e4bbf5d5f7b78b69a419b5d4970/auctions.json",
          "lastModified": 1454101069000
        }
      ]
    }

    Indeed JSON is minified.
]]

require('workshop.base')

local file_as_string = request('!.file.as_string')
local json_as_table = request('!.formats.json.load')

local json_link = arg[1]
local servername = string.match(json_link, '.*%/([%w%-]+)') or json_link
local auc_link_data = json_as_table(file_as_string(json_link))

local snapshot_time = auc_link_data.files[1].lastModified / 1000
local snapshot_path = auc_link_data.files[1].url

local filetime = os.date('%Y-%m-%dT%H_%M', snapshot_time)

local result = ('%s %s_%s.json'):format(snapshot_path, servername, filetime)
print(result)

--[[
~ 2013-09
2016-01-31
2016-03-22
]]
