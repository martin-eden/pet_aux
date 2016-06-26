-- Dumps table to lua code which recreates table.

local assembly_order = request('^.graph.assembly_order')

local default_table_iterator = request('^.table.ordered_pass')

local create_name_giver =
  function()
    local table_names = {}
    local last_table_number = 0

    local gen_new_name =
      function()
        last_table_number = last_table_number + 1
        local result = 't_' .. last_table_number
        return result
      end

    local get_table_name =
      function(t)
        table_names[t] = table_names[t] or gen_new_name()
        -- print(('<%s> has a name "%s"'):format(t, table_names[t]))
        return table_names[t]
      end

    return
      {
        get_table_name = get_table_name,
      }
  end

local create_line_adder =
  function()
    local lines = {}

    local add_line =
      function(s)
        lines[#lines + 1] = tostring(s)
      end

    local get_result =
      function()
        local result
        result = table.concat(lines, '\n')
        return result
      end

    return
      {
        add_line = add_line,
        get_result = get_result,
      }
  end


local looks_like_name = request('^.verify.lua_identifier')
assert_function(looks_like_name)

local get_num_refs =
  function(node_rec)
    local result = 0
    if node_rec.refs then
      for parent, parent_keys in pairs(node_rec.refs) do
        for field in pairs(parent_keys) do
          result = result + 1
        end
      end
    end
    return result
  end

local table_names = {}

local tostring_any = request('^.string.tostring_any')
local tostring_any_params =
  {
    table_iterator = default_table_iterator,
    initial_deep = 1,
    table_names = table_names,
  }

local may_print_inline =
  function(node_rec)
    return
      not node_rec or
      (
        node_rec and
        (get_num_refs(node_rec) <= 1) and
        not node_rec.part_of_cycle
      )
  end

local get_str =
  function(node, node_recs)
    local result
    local node_rec = node_recs[node]
    if may_print_inline(node_rec) then
      result = tostring_any(node, tostring_any_params)
    else
      result = node_rec.name
    end
    return result
  end

local get_key_str =
  function(node, node_recs)
    local result
    if looks_like_name(node) then
      result = tostring(node)
    else
      result = '[' .. get_str(node, node_recs) .. ']'
    end
    return result
  end

local get_qualified_key =
  function(node, node_recs)
    local result
    if looks_like_name(node) then
      result = '.' .. tostring(node)
    else
      result = '[' .. get_str(node, node_recs) .. ']'
    end
    return result
  end

local print_lua_code =
  function(node, node_recs, table_iterator, line_adder)
    local node_rec = node_recs[node]

    line_adder.add_line('local ' .. node_rec.name .. ' = {')
    for key, value in table_iterator(node) do
      if
        (not node_recs[key] or node_recs[key].is_defined) and
        (not node_recs[value] or node_recs[value].is_defined)
      then
        line_adder.add_line(('  %s = %s,'):format(get_key_str(key, node_recs), get_str(value, node_recs)))
      end
    end
    line_adder.add_line('}')
    node_recs[node].is_defined = true

    if node_rec.refs then
      for parent, parent_keys in pairs(node_rec.refs) do
        if node_recs[parent] and node_recs[parent].is_defined then
          for parent_key in pairs(parent_keys) do
            line_adder.add_line(
              ('%s%s = %s'):format(
                get_str(parent, node_recs),
                get_qualified_key(parent_key, node_recs),
                node_rec.name
              )
            )
          end
        end
      end
    end
  end

local table_to_lua_code =
  function(t, table_iterator)
    table_iterator = table_iterator or default_table_iterator
    local dfs_options =
      {
        also_visit_keys = true,
        table_iterator = table_iterator,
      }
    local node_recs, assembly_order = assembly_order(t, dfs_options)
    -- request('debug.assembly_order_printer').print(node_recs, assembly_order)

    local name_giver = create_name_giver()
    for i = 1, #assembly_order do
      local node = assembly_order[i]
      local node_rec = node_recs[node]
      if not may_print_inline(node_rec) then
        node_rec.name = name_giver.get_table_name(node)
        table_names[node] = node_rec.name
        -- local debug_chunk = ('(%s, %s)'):format(get_num_refs(node_rec), node_rec.part_of_cycle)
        -- node_rec.name = node_rec.name .. debug_chunk
      end
    end
    node_recs[t].name = 'result'

    local line_adder = create_line_adder()
    for i = 1, #assembly_order do
      local node_rec = node_recs[assembly_order[i]]
      if not may_print_inline(node_rec) or (assembly_order[i] == t) then
        print_lua_code(assembly_order[i], node_recs, table_iterator, line_adder)
      end
      node_rec.is_defined = true
    end
    line_adder.add_line('return result')

    local result = line_adder.get_result()
    return result
  end

return table_to_lua_code
