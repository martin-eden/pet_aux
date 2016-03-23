require('base_structs.#base')

local file_as_string = request('base_structs.file.as_string')
local json_as_table = request('base_structs.parse.json')

local json_realms_list_filename = arg[1]
local json_realms_list = file_as_string(json_realms_list_filename)
local realms_list = json_as_table(json_realms_list)

local results = {}
for i = 1, #realms_list.realms do
  local rec = realms_list.realms[i]
  results[i] = {slug = rec.slug, name = rec.name, locale = rec.locale}
end
table.sort(results, function(a, b) return a.slug < b.slug end)

local dfs = request('base_structs.graph.dfs_pass')
local lua_printer = request('base_structs.graph.dfs_pass.printers.lua')
local result = dfs(results, nil, lua_printer)

print(result)
