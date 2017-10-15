require('workshop.base')

if (#arg ~= 2) then
  print([[
Converts JSON to Lua table.

Usage: <f_in> <f_out>
]]
  )
  return
end

local json_input_file = arg[1]
local lua_output_file = arg[2]

local file_as_string = request('!.file.as_string')
local parse_json = request('!.formats.json.load')
local table_to_str = request('!.formats.lua_table.save')

local json_str = file_as_string(json_input_file)
local data = parse_json(json_str)
data = data or {}
local lua_str = table_to_str(data)
local f_out = assert(io.open(lua_output_file, 'w'))
f_out:write(lua_str)
f_out:close()
