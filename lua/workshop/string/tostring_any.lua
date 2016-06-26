--[[
  Straightforward implementation of printing lua table
  as lua table definition.

  Not suitable for tables with cross-links in keys or values.

  Trying to find the balance between simplicity and nice
  looking result.

  2016-04-22
--]]
local quote_string = request('^.string.quote')
-- local quote_string = request('^.string.quote_noesc')

local printers =
  {
    ['nil'] =
      function(node)
        return 'nil'
      end,
    ['boolean'] =
      function(node)
        if (node == false) then
          return 'false'
        else
          return 'true'
        end
      end,
    ['number'] =
      function(node)
        return tostring(node)
      end,
    ['string'] =
      function(node)
        return quote_string(node)
      end,
    ['function'] =
      function(node)
        return quote_string(tostring(node))
        -- return quote_string(string.dump(node))
      end,
    ['userdata'] =
      function(node)
        return quote_string(tostring(node))
      end,
    ['thread'] =
      function(node)
        return quote_string(tostring(node))
      end,
  }

local is_identifier = request('^.verify.lua_identifier')

local params
local state

printers['table'] =
  function(node)
    if params.table_names[node] then
      return params.table_names[node]
    end
    if state.visited[node] then
      return '*'
    end
    state.visited[node] = true
    local result = {}
    table.insert(result, '{')
    state.deep = state.deep + 1
    local indent = (params.indent_chunk):rep(state.deep)
    for k, v in params.table_iterator(node) do
      local fmt_str
      local key_str
      if is_identifier(k) then
        fmt_str = '%s%s = %s,'
        key_str = k
      else
        fmt_str = '%s[%s] = %s,'
        key_str = printers[type(k)](k)
      end
      local val_str = printers[type(v)](v)
      local line = (fmt_str):format(indent, key_str, val_str)
      table.insert(result, line)
    end
    state.deep = state.deep - 1
    indent = (params.indent_chunk):rep(state.deep)
    table.insert(result, ('%s}'):format(indent))
    result = table.concat(result, '\n')
    return result
  end

local default_params =
  {
    table_names = {},
    table_iterator = pairs,
    indent_chunk = '  ',
    initial_deep = 0,
  }

local clone = request('^.table.clone')
local patch = request('^.table.patch')
local simple_print =
  function(value, a_params)
    if is_table(a_params) then
      params = clone(default_params)
      patch(params, a_params)
    else
      params = default_params
    end
    state = {
      visited = {},
      deep = params.initial_deep,
    }
    return printers[type(value)](value)
  end

return simple_print
