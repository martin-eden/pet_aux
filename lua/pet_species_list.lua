require('workshop.base')

local file_as_string = request('!.file.as_string')
local table_from_str = request('!.formats.lua_table.load')
local table_to_str = request('!.formats.lua_table.save')

local lua_pet_list_filename = arg[1]
local filtered_output_file = arg[2]
local pet_list = table_from_str(file_as_string(lua_pet_list_filename))

local result = {}
for i = 1, #pet_list.pets do
  local rec = pet_list.pets[i]
  result[rec.stats.speciesId] = rec.name
end

local filtered_str = table_to_str(result)

local f_out = assert(io.open(filtered_output_file, 'w'))
f_out:write(filtered_str)
f_out:close()
