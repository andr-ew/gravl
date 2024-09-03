local src = {}

do
    local add_actions = {}
    for i = 1,2 do
        add_actions[i] = patcher.crow.add_source(i)
    end

    local function crow_add()
        for _,action in ipairs(add_actions) do action() end
    end
    norns.crow.add = crow_add


    src.init_crow = crow_add
end

do
    src.lfos = {}

    
    for i = 1,2 do
        local stream = patcher.add_source{ name = 'lfo '..i, id = 'lfo_'..i }

        src.lfos[i] = lfos:add{
            min = 0,
            max = 5,
            depth = 0.1,
            mode = 'free',
            period = 0.25,
            action = stream,
        }
    end

    src.lfos.reset_params = function()
        for i = 1,2 do
            params:set('lfo_mode_lfo_'..i, 2)
            params:set('lfo_max_lfo_'..i, 5)
            params:set('lfo_lfo_'..i, 2)
        end
    end
end

do
    local stream = patcher.add_source{ name = 'midi', id = 'midi' }

    local middle_c = 60

    local m = midi.connect()
    m.event = function(data)
        local msg = midi.to_msg(data)

        if msg.type == "note_on" then
            local note = msg.note
            local volt = (note - middle_c)/12

            stream(volt) 
        end
    end

    src.midi = m
end

return src
