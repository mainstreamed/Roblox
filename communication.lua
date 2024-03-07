--services
local runservice = game:GetService('RunService');

--variables
local table_insert = table.insert;
local t = typeof;

-- setup
local communication = {};
communication.connections = {};
communication.connected = true;

communication.loop = function(dt)
    local runs = communication.connections;
    for i = 1, #runs do
        runs[i].func();
    end
end

communication.connection = runservice.Heartbeat:Connect(communication.loop)

function communication:connect(name)
    local connection = {};
    connection.functions = {};
    connection.connected = true;
    function connection:add(func)
        if (not connection.connected) then
            return;
        end

        local index = #connection.functions+1;

        local _function = {};
        _function.connected = true;
        function _function:disconnect()
            if (not _function.connected) then
                return;
            end 
            _function.connected = false;
            for i = 1, #connection.functions do
                if (i > index) then
                    connection.functions[i-1] = connection.functions[i];
                    connection.functions[i] = nil;
                end
            end

            connection.functions[index] = nil;
        end
        return _function;
    end
    function connection:disconnect()
        connection.func = function() end
    end
    connection.func = function()
        if (isfile(name)) then
            local content = readfile(name);
            delfile(name);
            for i = 1, #connection.functions do 
                connection.functions[i](content)
            end
        end
    end
    table_insert(communication.connections, connection);
    return connection;
end 
function communication:send(name, content)
    writefile(name, content);
end
function communication:destroy()
    if (not communication.connected) then 
        return;
    end
    communication.connected = false;
    communication.connection:Disconnect();
end

return communication
