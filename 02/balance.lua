#!/usr/bin/env tarantool

local log = require('log')
local netbox = require('net.box')
local http_server = require('http.server')

local hosts = {
    'admin:test@localhost:3301',
    'admin:test@localhost:3302',
    'admin:test@localhost:3303',
}

connections = {}

function addConnection(host)
    local conn = netbox.connect(host)
    local assert = assert(conn) 
    if assert == nil then 
        error('Assert error')
        os.exit(1)
    end
    log.info('Connected to %s', host)
    table.insert(connections, conn)
end

function rmConnection(conn_num)
    if conn_num >= #connections or conn_num <= 0 then
        print("no connection")
    else
        table.remove(connections, conn_num)
    end
end

for _, host in ipairs(hosts) do
    addConnection(host)
end

local req_num = 1
local function handler()
    local conn = connections[req_num]
    if req_num == #connections then
        req_num = 1
    else
        req_num = req_num + 1
    end

    if conn:is_connected() == false then
        log.info(req_num)
        if req_num == 1 then
            rmConnection(#connections)
        else
            rmConnection(req_num-1)
        end
        req_num = 1 
        result = handler()

        return {
            body = result.body,
            status = result.status,
        }

    else
        local result = conn:call('exec')

        return {
            body = result,
            status = 200,
        }
    end
end

local httpd = http_server.new('0.0.0.0', '8080', {log_requests = false})
local router = require('http.router').new()
router:route({ method = 'GET', path = '/' }, handler)

httpd:set_router(router)
httpd:start()