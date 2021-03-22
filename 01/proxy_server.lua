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
  -- local encode = yaml.encode(decode)
  -- print(encode)
  return decode
end


local function handler()
  local client = require('http.client').new({max_connections = 1})
  local requestGET = client:request('GET', "mail.ru")
  -- local encode = yaml.encode(requestGET)
  -- print(encode)
  -- print(requestGET.status)
  -- print(requestGET.reason)
  -- print(requestGET.headers)
  -- local encode = yaml.encode(requestGET.headers)
  -- print(encode)
  -- print(requestGET.body)
  -- print(requestGET.proto)
  return {
    status = requestGET.status,
    body = requestGET.body,
    reason = requestGET.reason,
    headers = requestGET.headers,
    proto = requestGET.proto
  }
end

local config = parseConfig()
local router = require('http.router').new() 
router:route({ method = 'GET', path = '/' }, handler)

local server = require('http.server').new(config.proxy.bypass.host, config.proxy.bypass.port)
server:set_router(router)

server:start()


