--[[
  Status: stable, optimizing
  Last mod.: 2016-02-16
]]

function quote(s)
  if (type(s) ~= 'string') then
    return s
  end
  s = s:gsub('%c', function(s) return string.format([[\x%02x]], s:byte(1, 1)) end)
  local cnt_q1 = 0
  for i in s:gmatch([[']]) do
    cnt_q1 = cnt_q1 + 1
  end
  local cnt_q2 = 0
  for i in s:gmatch([["]]) do
    cnt_q2 = cnt_q2 + 1
  end
  if (cnt_q1 <= cnt_q2) then
    s = s:gsub([[']], [[\']])
    return [[']] .. s .. [[']]
  else
    s = s:gsub([["]], [[\"]])
    return [["]] .. s .. [["]]
  end
end


function looks_like_name(s)
  return
    is_string(s) and
    string.match(s, '^[%a_][%w_%.]*[%w_]?$') and
    not string.match(s, '%.%.')
end


function load_table_from_string(table_str)
  local table_code = ('_table = ' .. table_str)
  local f, err_msg = load(table_code)
  if not f then
    print(err_msg)
  else
    f()
    return _table
  end
end


function json_as_table(json_str)
  json_str = string.gsub(json_str, '%[', '{')
  json_str = string.gsub(json_str, '%]', '}')
  json_str = string.gsub(json_str, '"([%w_-]+)":', '["%1"]=')
  return load_table_from_string(json_str)
end


function file_as_string(file_name)
  local in_file = io.open(file_name, 'r')
  if not in_file then
    return
  end
  local result = in_file:read('*a')
  in_file:close()
  return result
end


function split_string(s, delim)
  assert(is_string(s))
  delim = delim or '\n'
  if (string.sub(s, -#delim) ~= delim) then
    s = s .. delim
  end
  local result = {}
  for line in string.gmatch(s, '([^' .. delim .. ']*)' .. delim) do
    result[#result + 1] = line
  end
  return result
end


function copy_table(t)
  local result = {}
  for k, v in pairs(t) do
    result[k] = v
  end
  return result
end


function iterate_table(t, f, offset)
  local visited = {}

  local function print_key_value(k, v, offset)
    if is_string(k) or is_number(k) then
      local s = string.rep(' ', 2 * offset)
      if is_number(k) then
        s = s .. '[' .. k .. ']'
      else
        s = s .. k
      end
      s = s .. ' = '
      local sv = ''
      if is_table(v) then
        sv = '{}'
      else
        sv = v
      end
      print(s, sv)
    end
  end

  local function _iterate_table(t, offset)
    if visited[t] then
      return
    else
      visited[t] = true
    end
    for k, v in pairs(t) do
      f(k, v, offset, t)
      if is_table(v) then
        _iterate_table(v, offset + 1)
      end
    end
  end

  offset = offset or 0
  f = f or print_key_value
  if is_table(t) then
    _iterate_table(t, offset)
  end

  visited = nil
end


local type_rank = {
    ['nil'] = 0,
    ['boolean'] = 1,
    ['number'] = 3,
    ['string'] = 4,
    ['thread'] = 5,
    ['userdata'] = 6,
    ['function'] = 7,
    ['table'] = 8,
  }


function compare_values(a, b)
  return
    (type_rank[type(a)] < type_rank[type(b)]) or
    (((type_rank[type(a)] == type_rank[type(b)])) and (type_rank[type(a)] <= 4) and (a < b))
end


function compare_table_records(a, b)
  return
    (type_rank[type(a.value)] < type_rank[type(b.value)]) or
    ((type_rank[type(a.value)] == type_rank[type(b.value)]) and compare_values(a.key, b.key))
end


function table_to_array(t, f)
  f =
    f or
    function(a, b)
      return compare_values(a.key, b.key)
    end
  local r = {}
  for k, v in pairs(t) do
    r[#r + 1] = {key = k, value = v}
  end
  table.sort(r, f)
  return r
end


function array_to_table(t)
  local r = {}
  for k, v in ipairs(t) do
    r[v.key] = v.value
  end
  return r
end


function map_values(t)
  local r = {}
  for k, v in pairs(t) do
    r[v] = true
  end
  return r
end


function sorted_pairs(t, f)
  local a = table_to_array(t, f)
  local i = 0
  return
    function()
      i = i + 1
      if a[i] then
        return a[i].key, a[i].value
      else
        return
      end
    end
end


function recursive_table_concat(t, delim)
  local result = {}

  local function _recursive_table_concat(t)
    if is_table(t) then
      for i = 1, #t do
        _recursive_table_concat(t[i])
      end
    else
      result[#result + 1] = tostring(t)
    end
    return result
  end

  result = _recursive_table_concat(t)
  if is_table(result) then
    result = table.concat(result, delim)
  end

  return result
end


function dump_structure_old(s, level, max_level)
  level = level or 0
  max_level = max_level or math.huge
  local visited = {}
  local offs_chunk = string.rep(' ', 2)

  local function _dump_structure(s, level, prefix)
    local function get_field_str(f)
      if looks_like_name(f) then
        return f
      else
        return string.format('[%s]', _dump_structure(f, level + 1))
      end
    end

    if (level > max_level) then
      return '...'
    end

    prefix = prefix or ''

    local result_tbl = {}
    local offs = string.rep(offs_chunk, level)
    local result = ''
    local label = (visited[s] and string.format('--[[= %s ]]', visited[s])) or ''

    if not s then
      result = 'nil'
    elseif is_string(s) then
      result = quote(s)
    elseif is_number(s) then
      result = tostring(s)
    elseif is_boolean(s) then
      result = tostring(s)
    elseif is_function(s) then
      if not visited[s] then
        visited[s] = prefix
        --label = string.format(' --[[%s]]', prefix)
        local is_ok, func_dump = pcall(string.dump, s)
        if is_ok then
          result = 'load(...)' --'load(' .. quote(func_dump) .. ')'
        else
          result = 'function(...) end'
        end
      end
    elseif is_thread(s) then
      result = '<thread>'
    elseif is_userdata(s) then
      result = '<userdata>'
    elseif is_table(s) then
      if visited[s] then
        label = '{' .. label .. '}'
      else
        visited[s] = prefix
        result_tbl[#result_tbl + 1] = '{'
        --label = string.format('--[[%s]] ', prefix)
        --result_tbl[1] = label .. result_tbl[1]

        for k, v in sorted_pairs(s) do
          local k_str = get_field_str(k)
          local new_prefix = ''
          -- prefixes also consumes much memory as this is a strings containing all keys
          if looks_like_name(k) then
            new_prefix = prefix .. '.' .. k_str
          else
            new_prefix = prefix .. k_str
          end
          result_tbl[#result_tbl + 1] =
            offs .. offs_chunk ..
            -- here comes the memory problem: we generate every subtable as string:
            string.format(
              '%s = %s,',
              k_str,
              _dump_structure(v, level + 1, new_prefix)
              )
        end
        result_tbl[#result_tbl + 1] = offs .. offs_chunk .. '}'
        result = table.concat(result_tbl, '\n')
      end
    else
      result = '<unknown type passed>'
    end

    local mt_str = ''
    --for uServer sandbox compatibility
    if (_VERSION == 'L ua 5.2') then
      mt = getmetatable(s)
      if mt then
        mt_str = ',\n' .. offs .. offs_chunk .. 'metatable = ' .. _dump_structure(mt, level, prefix)
      end
    end
    return result .. label .. mt_str
  end

  return _dump_structure(s, level, '{}')
end


function dump_structure(s, writer_func, max_level)
  max_level = max_level or math.huge
  local visited = {}
  local offs_chunk = string.rep(' ', 2)

  local delim = '\n'

  local result = {}

  local function add_to_result(v)
    if writer_func then
      writer_func(delim)
      writer_func(v)
    else
      result[#result + 1] = v
    end
  end

  local function add_to_prev_result(v)
    if writer_func then
      writer_func(v)
    else
      if result[#result] then
        result[#result] = result[#result] .. v
      else
        add_to_result(v)
      end
    end
  end

  local function _dump_structure(s, level)
    if (level > max_level) then
      add_to_result('...')
      return
    end

    local offs = string.rep(offs_chunk, level)

    if not s then
      add_to_prev_result('nil')
    elseif is_string(s) then
      add_to_prev_result(quote(s))
    elseif is_number(s) then
      add_to_prev_result(tostring(s))
    elseif is_boolean(s) then
      add_to_prev_result(tostring(s))
    elseif is_function(s) then
      if not visited[s] then
        visited[s] = true
        add_to_prev_result('function(...) end')
        --[[
        local is_ok, func_dump = pcall(string.dump, s)
        if is_ok then
          add_to_prev_result('load(...)') --'load(' .. quote(func_dump) .. ')'
        else
          add_to_prev_result('function(...) end')
        end
        ]]
      end
    elseif is_thread(s) then
      add_to_prev_result('<thread>')
    elseif is_userdata(s) then
      add_to_prev_result('<userdata>')
    elseif is_table(s) then
      if not visited[s] then
        visited[s] = true

        add_to_prev_result('{')

        for k, v in sorted_pairs(s) do
          local k_str
          add_to_result(offs .. offs_chunk)
          if looks_like_name(k) then
            add_to_prev_result(k)
          else
            add_to_prev_result('[')
            _dump_structure(k, level + 1)
            add_to_prev_result(']')
          end

          add_to_prev_result(' = ')

          _dump_structure(v, level + 1)

          add_to_prev_result(',')
        end
        add_to_result(offs .. offs_chunk .. '}')
      end
    else
      add_to_prev_result('<unknown type passed>')
    end
    return
  end

  _dump_structure(s, 0)
  if not writer_func then
    return table.concat(result, delim)
  end
end


function dump_structures(...)
  local result = {}
  for i = 1, select('#', ...) do
    result[#result + 1] = dump_structure((select(i, ...)))
  end
  result = table.concat(result, '\n')
  return result
end


mem_drawer = {
  level = {},
  draw = function(self, x, y, c)
    c = c or 'x'
    self.level[y] = self.level[y] or ''
    if (#self.level[y] < x - 1) then
      self.level[y] = self.level[y] .. string.rep(' ', x - 1 - #self.level[y]) .. c
    else
      self.level[y] = self.level[y]:sub(1, x - 1) .. c .. self.level[y]:sub(x + 1, -2)
    end
  end,
  new = function()
    return {level = {}, draw = mem_drawer.draw, new = mem_drawer.new}
  end
  }


function get_table_nesting(t)
  local processing = {}

  local function _nested_levels(t, x, y)
    if processing[t] then
      return x - 1
    end
    processing[t] = true
    mem_drawer:draw(x, y, '(')
    local is_changed = false
    for k, v in sorted_pairs(t) do
      if is_table(v) then
        x = _nested_levels(v, x, y + 1) + 1
        is_changed = true
      end
    end
    if is_changed then
      x = x - 1
    else
      x = x + 1
    end
    mem_drawer:draw(x, y, ')')
    processing[t] = nil
    return x
  end

  _nested_levels(t, 1, 1)
  return table.concat(mem_drawer.level, '\n')
end


local function spawn_is_functions()
  local data_types = {'thread', 'userdata', 'function', 'table', 'string', 'number', 'boolean', 'nil'}
  for k, v in ipairs(data_types) do
    _G['is_' .. v] =
      function(a)
        return type(a) == v
      end
  end
end


local function self_test()
  print('*nil*', dump_structure(nil))
  print('*number*', dump_structure(1))
  print('*boolean*', dump_structure(not false))
  print('*string*', dump_structure('a'))
  print('*empty string*', dump_structure(''))
  print('*simple table*', dump_structure({a = 11}))
  print('*table with table in values*', dump_structure({a = {11}}))
  print('*table with table in keys*', dump_structure({[{x = 'a', {{w = {z = 'o'}, [{}] = {}, [{}] = {}, {123}}}}] = {y = 'b'}}))
  print(
    '*(new) table with table in keys*',
    dump_structure_new(
      {
        [{x = 'a', {{w = {z = 'o'}, [{}] = {}, [{}] = {}, {123}}}}] = {y = 'b'}
        }
      )
    )
  print(
    '*table*',
    dump_structure(
      {
        a = {x = 'a', {{w = {z = 'o'}, [{}] = {}, [{}] = {}, {123}}}},
        b = {y = 'b'}
        }
      )
    )
  print(
    '*(new) table*',
    dump_structure_new(
      {
        a = {x = 'a', {{w = {z = 'o'}, [{}] = {}, [{}] = {}, {123}}}},
        b = {y = 'b'},
        'abc',
        {'def'},
        }
      )
    )
  -- print('*environment*', dump_structure(_G))
  --[[
  print(
    '*(table_concat)*',
    recursive_table_concat(
      {'a', 'b', {'c', {'d', 17, {'e'}, 'f'}}},
      '---'
      )
    )
  ]]
end


if (_VERSION == 'Lua 5.2') then
  spawn_is_functions()
else
  --for uServer sandbox compatibility
  function is_thread(a) return type(a) == 'thread' end
  function is_userdata(a) return type(a) == 'userdata' end
  function is_function(a) return type(a) == 'function' end
  function is_table(a) return type(a) == 'table' end
  function is_string(a) return type(a) == 'string' end
  function is_number(a) return type(a) == 'number' end
  function is_boolean(a) return type(a) == 'boolean' end
  function is_nil(a) return type(a) == 'nil' end
end

-- self_test()

--[[
2013-07-12
2016-02-16
]]

