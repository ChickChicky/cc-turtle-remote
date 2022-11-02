local JSON = require('json')

local api = {}
for k,v in pairs(turtle) do api[k] = turtle[v] end -- copies all default turtle functions

local envData = JSON.loadKey('./data.json','envData')
if envData == nil then
    envData = {
        x=0,y=0,z=0, -- position
        dir=0, -- orientation (0: North z+, 1: East x+, 2: South z-, 3: West x-)
        inventory = {}, selectedSlot = 0
    }
    for i=1,16 do
        envData.inventory[i] = turtle.getItemDetail(i,true)
    end
    envData.selectedSlot = turtle.getSelectedSlot()
end
local ws

function api.connectWS(socket) 
    ws = socket
end

local lu = -math.huge

function api._mainloop()
    -- moved to a single update function, "updateEnvData" became "update" nad now concentrates all the functions
    -- function updateWS()
    --     while true do os.queueEvent('lol') os.queueEvent('lol') os.pullEvent()
    --         ws:send({type='status_update',env=envData})
    --         sleep(.1)
    --     end
    -- end
    function update()
        local ed = envData
        while true do 
            -- prevents too long without yielding error
            os.queueEvent('lol') os.pullEvent() sleep(.01)
            -- update inventory
            for i=1,16 do
                envData.inventory[i] = turtle.getItemDetail(i,true)
            end
            envData.selectedSlot = turtle.getSelectedSlot()
            -- update surrounding blocks
            _, ed.topBlock = turtle.inspectUp()
            _, ed.frontBlock = turtle.inspect()
            _, ed.bottomBlock = turtle.inspectDown()
            if type(ed.topBlock) == 'string' then ed.topBlock = {name='minecraft:air'} end
            if type(ed.frontBlock) == 'string' then ed.frontBlock = {name='minecraft:air'} end
            if type(ed.bottomBlock) == 'string' then ed.bottomBlock = {name='minecraft:air'} end
            -- update WS and file
            ws:send({type='status_update',env=envData})
            if os.epoch() - lu > 60000 then
                api.updateFile()
                lu = os.epoch()
            end
        end
    end
    --function updateEnvFile() while true do os.queueEvent('lol') os.pullEvent() api.updateFile() sleep(1) end end
    --parallel.waitForAll(update,updateEnvFile)
    update()
end

function api.updateFile()
    JSON.saveKey('./data.json','envData',envData)
end

function api._forceSetPos(x,y,z)
    envData.x,envData.y,envData.z=x,y,z
end

function api._getPos()
    return {x=envData.x,y=envData.y,z=envData.z,str='< x='..tostring(envData.x)..'; y='..tostring(envData.y)..'; z='..tostring(envData.z)..' >'} 
end

function api._getOrient()
    return envData.dir
end

function api._forceSetOrient(o)
    envData.dir = o%4
end

function api.forward()
    local good, err = turtle.forward()
    if good then
        if      envData.dir == 0 then -- north
            envData.z = envData.z-1
        elseif envData.dir == 1 then -- east
            envData.x = envData.x+1
        elseif envData.dir == 2 then -- south
            envData.z = envData.z+1
        elseif envData.dir == 3 then -- west
            envData.x = envData.x-1
        end
    end
    return good, err
end

function api.back()
    local good, err = turtle.back()
    if good then
        if      envData.dir == 0 then -- north
            envData.z = envData.z+1
        elseif envData.dir == 1 then -- east
            envData.x = envData.x-1
        elseif envData.dir == 2 then -- south
            envData.z = envData.z-1
        elseif envData.dir == 3 then -- west
            envData.x = envData.x+1
        end
    end
    return good, err
end

function api.up()
    local good, err = turtle.up()
    if good then
        envData.y = envData.y+1
    end
    print(good,err,envData.y)
    return good, err
end

function api.down()
    local good, err = turtle.down()
    if good then
        envData.y = envData.y-1
    end
    return good, err
end

function api.turnLeft()
    local good, err = turtle.turnLeft()
    if good then
        envData.dir = (envData.dir-1)%4
    end
    return good, err
end

function api.turnRight()
    local good, err = turtle.turnRight()
    if good then
        envData.dir = (envData.dir+1)%4
    end
    return good, err
end

return api