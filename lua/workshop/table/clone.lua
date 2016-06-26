local cloned

local clone
clone =
  function(node)
    if is_table(node) then
      local result
      if cloned[node] then
        -- print(('"%s" is cloned, returning clone "%s"'):format(tostring(node), tostring(cloned[node])))
        result = cloned[node]
      else
        result = {}
        cloned[node] = result
        for k, v in pairs(node) do
          result[clone(k)] = clone(v)
        end
      end
      return result
    else
      return node
    end
  end

local clone_outer =
  function(node)
    cloned = {}
    return clone(node)
  end

return clone_outer
