function main() end
term.clear()
term.setCursorPos(1,1)

local json = require('json') -- kinda useless
local websocket = require('websocket')
local turtle_lib = require('turtle_wrapper')
function concatTables(...)
    local tables = {...}
    local tabl = {}
    for _,t in ipairs(tables) do
        for k,v in pairs(t) do
            tabl[k] = v
        end
    end
    return tabl
end
print('APIs loaded')

local ws = websocket.connect('ws://localhost:8080',{['Sec-WebSocket-Protocol']='turtle'})

if ws == nil then
    print('ws server is offline')
    while true do 
        ws = websocket.connect('ws://localhost:8080',{['Sec-WebSocket-Protocol']='turtle'})
        if ws ~= nil then break end
    end
    os.reboot()
end
print('ws connection done')

local data
if fs.exists('./data.json') then
    print('found internal data file')
    data = json.load('./data.json')
else
    print('no internal data file found')
    data = {}
end
print('internal data loading done')

-- connection
if data.id ~= nil then
    ws:send({type='connect',id=data.id})
    local resp = ws:receive()
    if resp.newId then
        data.id = resp.id
        print('receved new ID: '..tostring(data.id))
        os.setComputerLabel('Computer '..tostring(data.id))
    else 
        print('id already stored')
    end
else
    ws:send({type='connect',id=nil})
    local resp = ws:receive()
    data.id=resp.id
    print('receved new ID: '..tostring(data.id))
    os.setComputerLabel('Computer '..tostring(data.id))
end
json.save('./data.json',data)
print('id update done')

turtle_lib.connectWS(ws)

term.clear()
term.setCursorPos(1,1)

term.setTextColor(colors.cyan)
print('          remote control slave')
term.setTextColor(colors.brown)
print()

-- mainloop
function mainloop()
    while true do

        os.queueEvent('lol') os.pullEvent() sleep(.01)

        --if pcall(function()

            -- eval
            ws:send({type='ready',action='eval'})
            local resp = ws:receive()
            if resp.func ~= '' then
                print(resp.func)
                load(resp.func,resp.func,'bt',concatTables(_ENV,_G,{turtle=concatTables(turtle,turtle_lib)}))()
            end

            --[[
            -- status (moved to the wrapper)
            env = {}
            _, env.top_block = turtle.inspectUp()
            _, env.front_block = turtle.inspect()
            _, env.bottom_block = turtle.inspectDown()
            ws:send({ type = 'status_update',
                env = env
            })
            --]]

        --end) then else

            --print('ws server disconnected')
            --os.reboot()
            --return

        --end
    end
end

parallel.waitForAll(mainloop,turtle_lib._mainloop)