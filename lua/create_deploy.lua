package.path = package.path .. ';../../../../?.lua;../?.lua'
require('workshop.base')

local request_calls =
  {
    '!.file.as_string',
    '!.formats.json.load',
    '!.formats.lua_table.save',
    '!.table.ordered_pass',
    '!.formats.lua_table.load'
  }
for i = 1, #request_calls do
  request(request_calls[i])
end

local used_files = request('workshop.system.get_loaded_module_files')()

local deploy_script = request('workshop.formats.deploy_script.interface')
deploy_script.save_script(used_files)
