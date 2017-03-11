require('workshop.base')

local file_as_string = request('!.file.as_string')
local table_from_str = request('!.formats.lua_table.load')

local auc_list_filename = arg[1]
local auc_list_str = file_as_string(auc_list_filename)
local auc_list = table_from_str(auc_list_str)

local config_name = arg[2]
local config = dofile(config_name)
local used_realms = config.realms
local used_pets = config.pets

local list_all_pets
if not used_pets then
  list_all_pets = true
else
  for i = 1, #used_pets do
    used_pets[used_pets[i]] = true
  end
end

local pet_list_name = arg[3]
local pets = table_from_str(file_as_string(pet_list_name))

local current_results_name = arg[4]
local results = table_from_str(file_as_string(current_results_name))
assert(results)

local realm_name
for i = 1, #used_realms do
  for j = 1, #auc_list.realms do
    if (auc_list.realms[j].name == used_realms[i]) then
      if not realm_name then
        realm_name = used_realms[i]
      else
        realm_name = realm_name .. '/' .. used_realms[i]
      end
    end
  end
end

local add_pet =
  function(pet_name, category, buyout)
    results[pet_name] = results[pet_name] or {}
    results[pet_name][realm_name] = results[pet_name][realm_name] or {}
    results[pet_name][realm_name][category] =
      results[pet_name][realm_name][category] or buyout
    if (buyout < results[pet_name][realm_name][category]) then
      results[pet_name][realm_name][category] = buyout
    end
  end

local category_low = 1
local category_high = 2
local battle_stone_id = 92741
local battle_stone_name = 'Flawless Battle-Stone'
local missing_pet_idx_complained = {}
for i = 1, #auc_list.auctions do
  local rec = auc_list.auctions[i]
  if (rec.item == battle_stone_id) then
    add_pet(battle_stone_name, category_low, rec.buyout)
  end
  if rec.petSpeciesId and rec.buyout > 0 then
    local pet_id = rec.petSpeciesId
    local pet_name = pets[pet_id]
    if
      not pet_name and
      not missing_pet_idx_complained[pet_id]
    then
      io.stderr:write(
        ('Not found pet name for id "%d". Probably "species.json" file is outdated.\n'):
        format(pet_id)
      )
      missing_pet_idx_complained[pet_id] = true
    end
    if pet_name and (list_all_pets or used_pets[pet_name]) then
      local pet_breed = rec.petBreedId
      local level = rec.petLevel

      local category
      if (level < 25) then
        category = category_low
      else
        category = category_high
      end

      add_pet(pet_name, category, rec.buyout)
    end
  end
end

local table_to_str = request('!.formats.lua_table.save')
print(table_to_str(results))
