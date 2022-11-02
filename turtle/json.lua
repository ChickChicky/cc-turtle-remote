local json = {}

json.loadKey = function (path,k)
    local fd = io.open(path,'r')
    local c = fd:read('a')
    io.close(fd)
    return textutils.unserialiseJSON(c)[k]
end

json.saveKey = function (path,k,v)
    local fd = io.open(path,'r')
    local c = textutils.unserialiseJSON(fd:read('a'))
    fd:close()

    c[k] = v

    local fd = io.open(path,'w')
    fd:write(textutils.serialiseJSON(c))
    fd:close()
end

json.load = function (path)
    local fd = io.open(path,'r')
    local c = textutils.unserialiseJSON(fd:read('a'))
    fd:close()
    return c
end

json.save = function (path,data)
    local fd = io.open(path,'w')
    fd:write(textutils.serialiseJSON(data))
    fd:close()
end

json.encode = textutils.serialiseJSON
json.parse = textutils.unserialiseJSON

return json