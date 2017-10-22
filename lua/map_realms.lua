--[[
  Filter data from .json realms description.
]]

require('workshop.base')

local file_as_string = request('!.file.as_string')
local table_from_str = request('!.formats.lua_table.load')
local table_to_str = request('!.formats.lua_table.save')
local map_values = request('!.table.map_values')

local lua_realms_list_filename = arg[1]
local output_file_name = arg[2]
local realms_list = table_from_str(file_as_string(lua_realms_list_filename))

local result = {}
for i = 1, #realms_list.realms do
  local rec = realms_list.realms[i]
  result[rec.name] =
    {
      slug = rec.slug,
      connected_realms = map_values(rec.connected_realms),
    }
end

local filtered_str = table_to_str(result)

local f_out = assert(io.open(output_file_name, 'w'))
f_out:write(filtered_str)
f_out:close()


--[[
  Sample JSON:

  {
    "realms": [
      {
        "type":"pve",
        "population":"low",
        "queue":false,
        "status":true,
        "name":"Blade's Edge",
        "slug":"blades-edge",
        "battlegroup":"Glutsturm / Emberstorm",
        "locale":"en_GB",
        "timezone":"Europe/Paris",
        "connected_realms":["blades-edge","eonar","veknilash"]
      },
      ...
    ]
  }

  Produced Lua:

  {
    ["Blade's Edge"] = {
      slug = 'blades-edge',
      connected_realms = {
        ['blades-edge'] = true,
        ['eonar'] = true,
        ['veknilash'] = true,
      },
    },
    ...
  }
]]
