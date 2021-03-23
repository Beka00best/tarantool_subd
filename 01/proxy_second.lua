-- Здесь я сделал по-другому. Это второй вариант.

local fio = require('fio')
local yaml = require('yaml')
local uri = require('uri')

local function hello()
  return {
      status = 200,
      body = 'hello, world'
  }
end

local function parseConfig()
  local file = fio.open('config.yml', {'O_RDONLY'})
  if file == nil then
    print('File not opened')
  else
    print('File opened')
  end
  local config = file:read()
  file:close()
  local decode = yaml.decode(config)
  return decode
end

local config = parseConfig()

local function handler()
  local client = require('http.client').new({max_connections = 1})
  local requestGET = client:request('GET', 'http://'..config.proxy.bypass.host..':'..config.proxy.bypass.port,'',{timeout = 1})
  return {
    status = requestGET.status,
    reason = requestGET.reason,
    headers = requestGET.headers,
    body = requestGET.body,
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

make_response(config.proxy.bypass.host, config.proxy.bypass.port, hello)
make_response(config.proxy.bypass.host, config.proxy.port, handler)
