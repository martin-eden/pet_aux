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

for i = 1, #used_realms do
  local realm_name = used_realms[i]
  if full_realms_list[realm_name] then
    print(full_realms_list[realm_name])
  end
end
