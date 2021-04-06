local fio = require('fio')
local yaml = require('yaml')
local uri = require('uri')

local function hello() -- ответ локальному серверу
  return {
      status = 200,
      body = 'hello, world'
  }
end

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
  print(requestGET.status)
  print(requestGET.body)
  return {
    status = requestGET.status,
    headers = requestGET.headers,
    body = requestGET.body
  }
end

local function make_response(host, port, func)
  local server = require('http.server').new(host, port) 
  local router = require('http.router').new()
  router:route({ method = 'GET',path = '/'}, func)
  server:set_router(router)
  server:start()
end


if config.proxy.bypass.host == 'localhost' then
  make_response('localhost', config.proxy.bypass.port, hello) -- проверка работы прокси-сервера на локальном сервере
end
make_response('localhost', config.proxy.port, handler)
