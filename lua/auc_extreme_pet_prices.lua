require('common')

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

for i = 1, #auc_list.auctions do
  local rec = auc_list.auctions[i]
  if rec.petSpeciesId and rec.buyout > 0 then
    local buyout = math.ceil(rec.buyout / 1e4)
    local pet_id = rec.petSpeciesId
    local pet_name = pet_by_id[pet_id].name
    if list_all_pets or config_pets[pet_name] then
      local pet_breed = rec.petBreedId
      local level = rec.petLevel

      local category
      if (level < 25) then
        category = '1..24'
      else
        category = '25'
      end

      results[pet_name] = results[pet_name] or {}
      results[pet_name][realm_name] = results[pet_name][realm_name] or {}
      results[pet_name][realm_name][category] =
        results[pet_name][realm_name][category] or
        buyout
      --min buyout: results[pet_name][realm_name][category]
      if (buyout < results[pet_name][realm_name][category]) then
        results[pet_name][realm_name][category] = buyout
      end
    end
  end
end

print('return ' .. dump_structure(results))
