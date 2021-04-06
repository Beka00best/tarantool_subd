local fio = require('fio')
local yaml = require('yaml')
local uri = require('uri')

local function parseConfig()
  local file, err = fio.open('config.yml', {'O_RDONLY'})
  if file == nil then
    print('File not opened', err)
    os.exit(1)
  else
    print('File opened')
  end
  local config = file:read()
  file:close()
  local decode, err = yaml.decode(config)
  if decode == nil then
    print('decode fail', err)
    os.exit(1)
  end
  return decode
end

local config = parseConfig()

local client = require('http.client').new({max_connections = 1})

local function handler()
  local requestGET = client:request('GET', 'http://'..config.proxy.bypass.host..':'..config.proxy.bypass.port,'',{timeout = 1})
  if requestGET.body == nil then
    requestGET.body = 'body: '.. 'nil' .. '\nreason: '..requestGET.reason .. '\nstatus: '..requestGET.status..'\n'
  end
  if requestGET.headers == nil then
    requestGET.headers = 'headers: ' ..'nil\n'
  end 
  -- print(requestGET.status)
  -- print(requestGET.headers)
  return {
    status = requestGET.status,
    reason = requestGET.reason,
    body = requestGET.body,
    headers = requestGET.headers,
    proto = requestGET.proto
  }
end

local function make_response(host, port, func)
  local server = require('http.server').new(host, port) 
  local router = require('http.router').new()
  router:route({ method = 'GET',path = '/'}, func)
  server:set_router(router)
  server:start()
end

make_response('localhost', config.proxy.port, handler)
