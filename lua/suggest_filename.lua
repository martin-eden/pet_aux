--[[
  Extracts download link and gives a neat file name for given JSON file
  for server.

  Usage: <json_auction_link>
]]
--[[
  Auction link JSON sample:

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

require('common')

local filename_time_format = '%04d-%02d-%02d_%02d_%02d'
local output_format = '%s %s_%s.json'
local json_link = arg[1]
local servername = string.match(json_link, '.*%/([%w%-]+)') or json_link
local auc_link = json_as_table(file_as_string(json_link))
local parsed_time = os.date('!*t', auc_link.files[1].lastModified / 1000)
local filetime =
  filename_time_format:format(
    parsed_time.year,
    parsed_time.month,
    parsed_time.day,
    parsed_time.hour,
    parsed_time.min
  )
result = output_format:format(auc_link.files[1].url, servername, filetime)
print(result)

--[[
~ 2013-09
2016-01-31
]]
