require('base_structs.#base')

local file_as_string = request('base_structs.file.as_string')
local json_as_table = request('base_structs.load_from.json')

local json_pet_list_filename = arg[1]
local json_pet_list = file_as_string(json_pet_list_filename)
local pet_list = json_as_table(json_pet_list)
-- print(dump_structure(pet_list))

local results = {}
for i = 1, #pet_list.pets do
  local rec = pet_list.pets[i]
  results[i] = {id = rec.stats.speciesId, name = rec.name}
end
table.sort(results, function(a, b) return a.id < b.id end)

local table_to_str = request('base_structs.save_to.table_to_lua_code')
print(table_to_str(results))
