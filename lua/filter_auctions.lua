require('workshop.base')

if (#arg ~= 2) then
  print([[
Filters records from parsed auction lua file to another file.

Usage: <f_in> <f_out>
]]
  )
  return
end

local adjust_price =
  function(price)
    return math.ceil(price / 10000)
  end

local battle_stone_id = 92741

local add_auc_rec =
  function(auctions, rec)
    rec.bid = adjust_price(rec.bid)
    rec.buyout = adjust_price(rec.buyout)
    auctions[#auctions + 1] = rec
  end

local filter =
  function(data)
    local result = {}
    result.realms = data.realms
    result.auctions = {}
    for i = 1, #data.auctions do
      local rec = data.auctions[i]
      if
        (rec.item == battle_stone_id) or
        (rec.petSpeciesId and (rec.buyout > 0))
      then
        add_auc_rec(result.auctions, rec)
      end
    end
    return result
  end

local auc_input_file = arg[1]
local filtered_output_file = arg[2]

local file_as_string = request('!.file.as_string')
local table_from_str = request('!.formats.lua_table.load')
local table_to_str = request('!.formats.lua_table.save')

local auc_str = file_as_string(auc_input_file)
local data = table_from_str(auc_str)

if not data or not next(data) then
  return
end

data = filter(data)
local filtered_str = table_to_str(data)

local f_out = assert(io.open(filtered_output_file, 'w'))
f_out:write(filtered_str)
f_out:close()
