require('workshop.base')

local file_as_string = request('!.file.as_string')
local table_from_str = request('!.formats.lua_table.load')

local results_file = arg[1]
if not results_file then
  print('Usage: <lua_file_with_results> [<context_length>]')
  return
end

local context_length = tonumber(arg[2]) or 2

local pets = table_from_str(file_as_string(results_file))
assert_table(pets)

-- <pet> <bracket> [<quality>] <*inner_place> <server> <price>
-- *inner_place is some marker to convenient grepping cheapest pets
local generate_compare_function =
  function(bracket)
    return
      function (a, b)
        local a_rank, b_rank
        a_rank = a.value[bracket] or math.huge
        b_rank = b.value[bracket] or math.huge
        return (a_rank < b_rank)
      end
  end

local sorted_pairs = request('!.table.ordered_pass')
local results = {}
for pet_name, servers in sorted_pairs(pets) do
  local fill_results =
    function(bracket)
      local num_processed = 0
      for server_name, bracket_prices in sorted_pairs(servers, generate_compare_function(bracket)) do
        local price = bracket_prices[bracket]
        if price then
          results[#results + 1] = {pet_name, bracket, '(' .. num_processed + 1 .. ')', server_name, price}
          num_processed = num_processed + 1
          if (num_processed > context_length) then
            break
          end
        end
      end
    end
  fill_results(1)
  fill_results(2)
end

--stingify results
--[[ too boring
local field_separator = '\t'
local record_separator = '\n'
for i = 1, #results do
  results[i] = table.concat(results[i], field_separator)
end
results = table.concat(results, record_separator)
--]]
local max_column_width = {}
local column_is_number = {}
for i = 1, #results do
  for j = 1, #results[i] do
    local cur_width = #(tostring(results[i][j] or ''))
    cur_width = math.min(cur_width, 50)
    if
      not max_column_width[j] or
      (cur_width > max_column_width[j])
    then
      max_column_width[j] = cur_width
    end
    if
      is_nil(column_is_number[j]) and
      tonumber(results[i][j])
    then
      column_is_number[j] = true
    end
  end
end
for i = 1, #results do
  for j = 1, #results[i] do
    local format_string
    if column_is_number[j] then
      format_string = string.format('%%%ds', max_column_width[j])
    else
      format_string = string.format('%%-%ds', max_column_width[j])
    end
    results[i][j] = string.format(format_string, results[i][j])
  end
end
--now it's ok
local field_separator = '\t'
for i = 1, #results do
  results[i] = table.concat(results[i], field_separator)
end
local record_separator = '\n'
results = table.concat(results, record_separator)
print(results)
