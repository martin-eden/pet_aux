local config_name = arg[1]
local realms_config = dofile(config_name)
if not realms_config then
  error(('Looks like config file "%s" is not loaded correctly.'):format(config_name))
end

local realms_name = arg[2]
local full_realms_list = dofile(realms_name)
if not (full_realms_list) then
  error(('Looks like realms file "%s" is not loaded correctly.'):format(realms_name))
end

local realms = {}
for i = 1, #full_realms_list do
  local rec = full_realms_list[i]
  realms[rec.name] = rec.slug
end

for i = 1, #realms_config do
  local realm_name = realms_config[i]
  if realms[realm_name] then
    print(realms[realm_name])
  end
end
