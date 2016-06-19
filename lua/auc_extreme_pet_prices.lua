require('base_structs.#base')

local file_as_string = request('base_structs.file.as_string')
local json_as_table = request('base_structs.load_from.json')

local json_auc_list_filename = arg[1]
local json_auc_list = file_as_string(json_auc_list_filename)
local auc_list = json_as_table(json_auc_list)

local config_name = arg[2]
local config_realms, config_pets = dofile(config_name)
local list_all_pets
if not config_pets then
  list_all_pets = true
else
  for i = 1, #config_pets do
    config_pets[config_pets[i]] = true
  end
end

local pet_list_name = arg[3]
local pet_list = dofile(pet_list_name)

local pet_by_id = {}
for i = 1, #pet_list do
  local rec = pet_list[i]
  pet_by_id[rec.id] = rec
end

local current_results_name = arg[4]
local results = dofile(current_results_name)

local realm_name
for i = 1, #config_realms do
  for j = 1, #auc_list.realms do
    if (auc_list.realms[j].name == config_realms[i]) then
      if not realm_name then
        realm_name = config_realms[i]
      else
        realm_name = realm_name .. '/' .. config_realms[i]
      end
    end
  end
end

local add_pet =
  function(pet_name, category, buyout)
    local buyout = math.ceil(buyout / 1e4)
    results[pet_name] = results[pet_name] or {}
    results[pet_name][realm_name] = results[pet_name][realm_name] or {}
    results[pet_name][realm_name][category] =
      results[pet_name][realm_name][category] or
      buyout
    if (buyout < results[pet_name][realm_name][category]) then
      results[pet_name][realm_name][category] = buyout
    end
  end

local category_low = '1..24'
local category_high = '25'
local battle_stone_id = 92741
local battle_stone_name = 'Flawless Battle-Stone'
for i = 1, #auc_list.auctions do
  local rec = auc_list.auctions[i]
  if (rec.item == battle_stone_id) then
    add_pet(battle_stone_name, category_low, rec.buyout)
    add_pet(battle_stone_name, category_high, rec.buyout)
  end
  if rec.petSpeciesId and rec.buyout > 0 then
    local buyout = math.ceil(rec.buyout / 1e4)
    local pet_id = rec.petSpeciesId
    local pet_name = pet_by_id[pet_id].name
    if list_all_pets or config_pets[pet_name] then
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

local table_to_str = request('base_structs.save_to.table_to_lua_code')
print(table_to_str(results))
