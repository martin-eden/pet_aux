--[[
  For full realm names in [config] print list of slug names.

  These list is used to download auctions.
]]

require('workshop.base')

local file_as_string = request('!.file.as_string')
local table_from_str = request('!.formats.lua_table.load')

local config_file_name = arg[1]
local config_realms = dofile(config_file_name).realms
if not config_realms then
  error(('Looks like config file "%s" is not loaded correctly.'):format(config_file_name))
end

local realms_file_name = arg[2]
local full_realms_list = table_from_str(file_as_string(realms_file_name))
if not full_realms_list then
  error(('Looks like realms file "%s" is not loaded correctly.'):format(realms_file_name))
end

local realms_processed = {}
for _, realm_name in ipairs(config_realms) do
  local realm_rec = full_realms_list[realm_name]
  -- If config has correct full realm name and it is not previously mentioned:
  if realm_rec and not realms_processed[realm_rec.slug] then
    print(realm_rec.slug)
    for k in pairs(realm_rec.connected_realms) do
      realms_processed[k] = true
    end
  end
end
