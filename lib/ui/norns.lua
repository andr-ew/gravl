local buffers = grvl.buffers

local x, y, w, h
do
    local mar = { top = 0, bottom = 0, left = 2, right = 0 }
    local top, bottom = mar.top, 64 - mar.bottom
    local left, right = mar.left, 128-mar.right
    w = 128 - mar.left - mar.right
    h = 64 - mar.top - mar.bottom
    x = { left, left + w*(1/4), 64, left + w*(3/4)  }
    y = { top, }
end
local text_mul_y = 9

local function Destination(args)
    local id = args.id
    local p = params:lookup_param(id)
    local spec = p.controlspec
    local name = p.name

    local _label = Screen.text()
    local _value = Screen.text()
    local _enc = Enc.control() --TODO: select component by param type (p.t)

    return function(props)
        local x = x[props.map_x] + (props.map_x >2 and (w/4 - 5) or 0)
        local flow = props.map_x >2 and 'left' or 'right'

        _label{
            x = x,
            -- x = x[props.map_x] + w/8 - 2,
            y = y[1] + text_mul_y*props.map_y,
            text = string.upper(name),
            level = props.levels_label[props.focused and 2 or 1],
            font_face = 2,
            flow = flow,
            -- flow = 'center',
        }
        if props.focused then
            _value{
                x = x,
                y = y[1] + text_mul_y*5 + 1,
                -- text = util.round(params:get(id), 0.01),
                text = string.format('%.2f %s', params:get(id), spec.units),
                level = props.levels[2],
                font_face = 2,
                flow = flow,
            }
            _enc{
                n = (props.map_x - 1)%2 + 2,
                controlspec = spec,
                state = crops.of_param(id),
            }
        end
    end
end

local function App(args)
    local map = args.map

    local _focus = Enc.integer()

    local _map = {}
    for y = 1,4 do
        _map[y] = {}
        for x = 1,4 do
            if map[y][x] then
                local prefix = map[y][x]
                local chan = (x <3) and 1 or 2
                _map[y][x] = Patcher.enc.destination(Destination{ id = prefix..chan })
            end
        end
    end

    return function()
        _focus{
            n = 1, max = 8, sensitivity = 1/4,
            state = crops.of_variable(grvl.norns_focus, function(v) 
                grvl.norns_focus = v
                crops.dirty.screen = true 
            end)
        }

        local f_y = (grvl.norns_focus - 1)%4 + 1
        local f_x = (grvl.norns_focus - 1)//4 + 1

        if crops.mode == 'redraw' then 

            -- focus rectangles
            screen.level(15)
            for i = 1,2 do
                screen.rect(
                    x[i + (f_x - 1)*2] - 1,
                    y[1] + text_mul_y*(f_y - 1) + 2,
                    w/4 - 2,
                    8 
                )
                screen.fill()
            end 

            --phase
            for chan = 1,2 do
                local left, top = x[(chan - 1)*2 + 1], y[1] + text_mul_y*5.5 + 2
                local width = w/2 - 2

                -- screen.level(4)
                -- screen.move(left, top)
                -- screen.line_rel(width, 0)
                -- screen.stroke()

                local st = (
                    patcher.get_destination_plus_param('loop_start_'..chan)
                    / grvl.time_volt_scale
                )
                local en = (
                    patcher.get_destination_plus_param('loop_end_'..chan) 
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

                local buf = patcher.get_destination_plus_param('buffer_'..chan)
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

        for y = 1,4 do for x = 1,4 do
            local chan = (x <3) and 1 or 2

            _map[y][x](map[y][x]..chan, grvl.active_src, {
                focused = (y == f_y and chan == f_x),
                map_x = x,
                map_y = y,
                levels = { 4, 15 },
                levels_label = (
                    arc_connected and grvl.arc_focus[y][x] > 0
                ) and { 10, 0 } or { 4, 0 },
            })
        end end
    end
end

return App
