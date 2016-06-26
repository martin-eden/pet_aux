local linear_quote =
  function(s)
    local result = s
    result = result:gsub('[%c' .. [[%\]] .. ']', function(s) return string.format([[\x%02x]], s:byte(1, 1)) end)
    local cnt_q1 = 0
    for i in result:gmatch("'") do
      cnt_q1 = cnt_q1 + 1
    end
    local cnt_q2 = 0
    for i in result:gmatch('"') do
      cnt_q2 = cnt_q2 + 1
    end
    if (cnt_q1 <= cnt_q2) then
      result = "'" .. result:gsub([[']], [[\']]) .. "'"
    else
      result = '"' .. result:gsub([["]], [[\"]]) .. '"'
    end
    return result
  end

return linear_quote
