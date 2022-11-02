local json = require('json')

local api = {}

local wsConnection = {}
wsConnection.__index = wsConnection
function wsConnection.new(ws) 
    local t = {}
    setmetatable(t,wsConnection)
    t.socket = ws
    return t
end
-- sending data
function wsConnection:sendRaw(rawData)
    return self.socket.send(rawData)
end
function wsConnection:send(data)
    return self:sendRaw(json.encode(data))
end
-- receiving data
function wsConnection:receiveRaw()
    return self.socket.receive()
end
function wsConnection:receive()
    local response,binary = self:receiveRaw()
    if response == nil then
        self:close()
        return
    else
        return json.parse(response)
    end
end
-- close socket
function wsConnection:close()
    return self.socket.close()
end
-- socket info
function wsConnection:isClosed()
    if pcall(function() self:send({type='ack'}) end) then
        return false
    else
        return true
    end
end
function wsConnection:isOpen()
    return not self:isClosed()
end

function api.connect(addr,headers)

    local socket = http.websocket(addr,headers)
    if socket == false then return end

    return wsConnection.new(socket)

end

return api