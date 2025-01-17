local buffers = grvl.buffers

local x, y, w, h
do
    local mar = { top = 0, bottom = 0, left = 1, right = 0 }
    local top, bottom = mar.top, 64 - mar.bottom
    local left, right = mar.left, 128-mar.right
    w = 128 - mar.left - mar.right
    h = 64 - mar.top - mar.bottom
    x = { left, left + w*(1/4), 64, left + w*(3/4), right }
    y = { top, }
end
local text_mul_y = 9

local label_width = w/4 - 2

local function Destination(args)
    local _label = Screen.text()
    local _value = Patcher.screen.destination(Screen.text())

    --TODO: select component by param type (p.t)
    local _enc = {
        control = Patcher.enc.destination(Enc.control()),
        number = Patcher.enc.destination(Enc.integer())
    }

    return function(props)
        local id = props.id
        local x = x[props.map_x] + (props.map_x >2 and (w/4 - 1) or 0)
        local flow = props.map_x >2 and 'left' or 'right'
        local p = params:lookup_param(id)
        local spec = p.controlspec
        local name = p.name
        local text = grvl.param_nicknames[name] or util.trim_string_to_width(name, label_width - 1)

        _label{
            x = x,
            -- x = x[props.map_x] + w/8 - 2,
            y = y[1] + text_mul_y*props.map_y,
            text = string.upper(text),
            level = props.levels_label[props.focused and 2 or 1],
            font_face = 2,
            flow = flow,
            -- flow = 'center',
        }
        if props.focused then
            _value(id, grvl.active_src, {
                x = x,
                y = y[1] + text_mul_y*5 + 1,
                -- text = util.round(params:get(id), 0.01),
                text = string.format(
                    '%.2f %s', 
                    grvl.get_param(id),
                    spec and spec.units or ''
                ),
                level = props.levels[2],
                font_face = 2,
                flow = flow,
            })
            _enc[spec and 'control' or 'number'](id, grvl.active_src, {
                n = (props.map_x - 1)%2 + 2,
                controlspec = spec,
                min = p.min, max = p.max,
                state = grvl.of_param(id),
            })
        end
    end
end

local function Gfx(thing)
    local data = {}
    for i = 1,128 do
        local init = (i > (thing * 64) and i < (thing + 1)*64) and math.random(1, 12) or 0
        data[i] = init
    end
    local idx = math.random(1, #data)
    local idx_last = idx
    local val = 8

    return function(props)
        if crops.mode == 'redraw' and crops.device == 'screen' then 
            local bit = 9 - (9 - grvl.get_param('bit_depth_'..1))
            if math.random() > (1/(8 * bit)) then
                local coin = (math.random() < (1/(4 * bit))) and math.random(0, 4) or 0
                local d = grvl.get_param('detritus_'..props.chan) + coin
                for ix,_ in ipairs(data) do
                    local lvl = data[(ix - 1)%#data + 1]
                    if lvl>0 then
                        screen.level(lvl)
                        for iy = 1,4 do
                            local det_off = (d - 1)*32*(iy)
                            local x, y = (ix + det_off)%#data, 32*(props.chan - 1) + 8*(iy - 1)
                            -- screen.move()
                            -- screen.line_rel(0, 8)
                            screen.rect(x, y, 1, 8)
                        end
                        screen.stroke()
                    end
                end

                local buf = grvl.get_param('buffer_'..props.chan)
                if 
                    buffers[buf].recorded 
                    or buffers[buf].manual 
                    or buffers[buf].loaded
                then
                    local r = grvl.values.rate_w[props.chan]
                    --mutating states in the render loop -- shhh! don't tell anyone
                
                    idx_last = idx
                    idx = (idx - 1 + r)%#data + 1

                    data[idx//1] = val

                    if (r>0 and idx<idx_last) or (r<0 and idx>idx_last) then
                        val = (val + 11) % 15
                    end
                end

                for x = 0, 1 do
                    for y = 0, 1 do
                        if math.random() < (1/(32 * bit)) then
                            screen.rect(x * 64, y * 32, 64, 32)
                            if math.random() > 0.5 then screen.level(0) end
                            screen.fill()
                            -- screen.fill((math.random() * 15) // 1)
                        end
                    end
                end
            else
                screen.rect(0, 0, 64, 64)
                screen.level(15)
                screen.fill()
            end
        end
    end
end

local function App(args)
    local _focus = Enc.integer()
    
    local _recs = {}
    for chan = 1,2 do
        _recs[chan] = Patcher.key_screen.destination(Components.norns.toggle_hold())
    end

    local _destinations = {}
    for y = 1,4 do
        _destinations[y] = {}
        for x = 1,4 do
            _destinations[y][x] = Destination()
        end
    end

    local EDIT, ERODE = 0, 1
    local view = 0
    local _view = Key.toggle()

    local _gfxs = { Gfx(math.random(0, 1)), Gfx(math.random(0, 1)) }

    return function(props)
        local map = grvl.map 

        _view{
            n = 1, state = crops.of_variable(view, function(v) 
                view = v
                crops.dirty.screen = true
            end)
        }

        if view == EDIT then
            _focus{
                n = 1, max = 8, sensitivity = 1/4,
                state = crops.of_variable(grvl.norns_focus, function(v) 
                    grvl.norns_focus = v
                    crops.dirty.screen = true 
                end)
            }

            local f_y = (grvl.norns_focus - 1)%4 + 1
            local f_x = (grvl.norns_focus - 1)//4 + 1

            if crops.mode == 'redraw' and crops.device == 'screen' then 
                -- focus rectangles
                screen.level(15)
                for i = 1,2 do
                    local off = f_x==1 and -1 or 2
                    screen.rect(
                        x[i + (f_x - 1)*2] + off,
                        y[1] + text_mul_y*(f_y - 1) + 2,
                        label_width,
                        8 
                    )
                    screen.fill()
                end 

                --phase
                for chan = 1,2 do
                    local left= x[(chan - 1)*2 + 1]
                    local top = y[1] + text_mul_y*5.5 + 2
                    local width = w/2 - 4
                    
                    if chan==2 then
                        left = left + 3
                    end

                    -- screen.level(4)
                    -- screen.move(left, top)
                    -- screen.line_rel(width, 0)
                    -- screen.stroke()

                    local st = (
                        grvl.get_param('loop_start_'..chan)
                        / grvl.time_volt_scale
                    )
                    local en = (
                        grvl.get_param('loop_end_'..chan) 
                        / grvl.time_volt_scale
                    )
                    local min = math.min(st, en)
                    local max = math.max(st, en)

                    screen.level(6)
                    screen.move(left + min*width, top)
                    screen.line(left + max*width, top)
                    screen.stroke()
                    screen.level(10)
                    screen.pixel(left + min*width, top)
                    screen.pixel(left + max*width, top)
                    screen.fill()

                    local buf = grvl.get_param('buffer_'..chan)
                    if 
                        buffers[buf].recorded 
                        or buffers[buf].manual 
                        or buffers[buf].loaded
                    then
                        local ph = buffers[buf].phase_seconds
                        local dur = buffers[buf].duration_seconds

                        screen.level(15)
                        screen.pixel(left + (ph / dur)*width, top)
                        screen.fill()
                    end
                end
            end

            for chan,_rec in ipairs(_recs) do
                _rec('record_'..chan, grvl.active_src, {
                    x = chan==1 and x[1]+0 or x[5]-1,
                    y = y[1] + text_mul_y*7 - 1,
                    n = chan + 1, 
                    -- id_toggle = 'record_'..chan, 
                    -- id_hold = 'clear_'..chan, 
                    state_toggle = grvl.of_param('record_'..chan),
                    action_hold = function() params:delta('clear_'..chan) end,
                    label_toggle = 'REC', label_hold = 'CLEAR',
                    levels = { 4, 15 },
                    font_face = 2,
                    flow = chan==2 and 'left' or 'right',
                })
            end

            for y = 1,4 do for x = 1,4 do
                local chan = (x <3) and 1 or 2
                local prefix = map[y][x]

                _destinations[y][x]{
                    id = prefix..chan,
                    focused = (y == f_y and chan == f_x),
                    map_x = x,
                    map_y = y,
                    levels = { 4, 15 },
                    levels_label = (
                        arc_connected and grvl.arc_focus[y][x] > 0
                    ) and { 10, 0 } or { 4, 0 },
                }
            end end
        elseif view == ERODE then
            for chan,_gfx in ipairs(_gfxs) do
                _gfx{ chan = chan }
            end
        end
    end
end

return App
