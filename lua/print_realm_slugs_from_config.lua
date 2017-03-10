require('workshop.base')

local file_as_string = request('!.file.as_string')
local table_from_str = request('!.formats.lua_table.load')

local config_name = arg[1]
local used_realms = dofile(config_name).realms
if not used_realms then
  error(('Looks like config file "%s" is not loaded correctly.'):format(config_name))
end

local realms_name = arg[2]
local full_realms_list = table_from_str(file_as_string(realms_name))
if not (full_realms_list) then
  error(('Looks like realms file "%s" is not loaded correctly.'):format(realms_name))
end

local realms = {}
for i = 1, #full_realms_list do
  local rec = full_realms_list[i]
  realms[rec.name] = rec.slug
end

for i = 1, #used_realms do
  local realm_name = used_realms[i]
  if realms[realm_name] then
    print(realms[realm_name])
  end
end
