local patch =
  function(t_src, t_patch)
    for k, v in pairs(t_patch) do
      if t_src[k] then
        t_src[k] = v
      end
    end
  end

return patch
