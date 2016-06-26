-- DFS-pass of given graph

local default_table_iterator = request('^.table.ordered_pass')
-- local default_table_iterator = pairs

local empty_func = function() end

local dfs =
  function(graph, options)
    assert_table(graph)
    options = options or {}
    assert_table(options)
    local handler = options.handler or empty_func
    assert_function(handler)
    local table_iterator = options.table_iterator or default_table_iterator
    assert_function(table_iterator)
    local iterate_table_keys = options.also_visit_keys

    local nodes_status = {}
    local time = 0

    local add_ref =
      function(child_rec, parent, parent_key)
        child_rec.refs = child_rec.refs or {}
        child_rec.refs[parent] = child_rec.refs[parent] or {}
        child_rec.refs[parent][parent_key] = true
      end

    local call_stack = {}
    local mark_cycle =
      function(cur_idx, dest_node)
        while true do
          local cur_node = call_stack[cur_idx]
          nodes_status[cur_node].part_of_cycle = true
          if (cur_node == dest_node) then
            break
          end
          cur_idx = cur_idx - 1
        end
      end

    local dfs_visit
    dfs_visit =
      function(node, deep)
        assert_table(node)
        call_stack[deep] = node
        local node_rec = nodes_status[node]
        assert_table(node_rec)
        time = time + 1
        node_rec.discovery_time = time
        node_rec.color = 'gray' --'processing'
        handler('discovered', node, node_rec, deep)
        for k, v in table_iterator(node) do
          if is_table(v) then
            nodes_status[v] = nodes_status[v] or {}
            if not nodes_status[v].color then
              nodes_status[v].parent = node
              nodes_status[v].parent_key = k
              dfs_visit(v, deep + 1)
            elseif (nodes_status[v].color == 'gray') then
              nodes_status[v].part_of_cycle = true
              mark_cycle(deep, v)
            end
            add_ref(nodes_status[v], node, k)
          end
          if is_table(k) and iterate_table_keys then
            nodes_status[k] = nodes_status[k] or {}
            if not nodes_status[k].color then
              nodes_status[k].parent = node
              nodes_status[k].parent_key = k
              dfs_visit(k, deep + 1)
            elseif (nodes_status[k].color == 'gray') then
              nodes_status[k].part_of_cycle = true
              mark_cycle(deep, k)
            end
            add_ref(nodes_status[k], node, k)
          end
        end
        node_rec.color = 'black' --'processed'
        time = time + 1
        node_rec.finish_time = time
        handler('processed', node, node_rec, deep)
      end

    nodes_status[graph] = {}
    dfs_visit(graph, 0)

    return nodes_status
  end

return dfs
