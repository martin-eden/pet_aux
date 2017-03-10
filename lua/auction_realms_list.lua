require('workshop.base')

local file_as_string = request('!.file.as_string')
local json_as_table = request('!.formats.json.load')

local json_realms_list_filename = arg[1]
local json_realms_list = file_as_string(json_realms_list_filename)
local realms_list = json_as_table(json_realms_list)

local results = {}
for i = 1, #realms_list.realms do
  local rec = realms_list.realms[i]
  results[rec.name] = rec.slug
end

local table_to_str = request('!.formats.lua_table.save')
print(table_to_str(results))
