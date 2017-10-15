--[[
  Receives file name with parsed auction link data.

  Returns neat JSON file name and URL link to it.

  Suggested file name is based on given file name (server name) and
  data from file (creation time).
]]

require('workshop.base')

local file_as_string = request('!.file.as_string')
local table_from_str = request('!.formats.lua_table.load')

local link_file_name = arg[1]
local servername = string.match(link_file_name, '.*%/([%w%-]+)') or link_file_name
local auc_link_data = table_from_str(file_as_string(link_file_name))

if not auc_link_data then
  return
end

local snapshot_time = auc_link_data.files[1].lastModified / 1000
local snapshot_path = auc_link_data.files[1].url

local filetime = os.date('%Y-%m-%dT%H_%M', snapshot_time)

local result = ('%s %s_%s.json'):format(snapshot_path, servername, filetime)
print(result)

--[[
~ 2013-09
2016-01-31
2016-03-22
2017-03-10
2017-10-15
]]
