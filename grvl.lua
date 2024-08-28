-- grvl
--
-- dual data pavement
--
-- version 0.2.0 @andrew
--
-- recommended: grid 
-- (128, 64, or midigrid)
--
-- documentation:
-- github.com/andr-ew/grvl

--device globals (edit for midigrid if needed)

g = grid.connect()
a = arc.connect()

arc_connected = a and (not (a.name == 'none'))
arc2 = a and a.device and string.match(a.device.name, 'arc 2')

--system libs

cs = require 'controlspec'
lfos = require 'lfo'

--git submodule libs

include 'lib/crops/core'
Key = include 'lib/crops/components/key'
Enc = include 'lib/crops/components/enc'
Screen = include 'lib/crops/components/screen'
Grid = include 'lib/crops/components/grid'
Arc = include 'lib/crops/components/arc'

pattern_time = include 'lib/pattern_time_extended/pattern_time_extended'

Produce = {}
Produce.grid = include 'lib/produce/grid'

patcher = include 'lib/patcher/patcher'
Patcher = include 'lib/patcher/ui/using_source_keys'

--script files

engine.name = 'Grvl'

grvl = {}
include 'lib/lib-grvl/globals'
include 'lib/globals'

mod_src = include 'lib/modulation-sources'
include 'lib/lib-grvl/params'
include 'lib/params'
Components = include 'lib/lib-grvl/ui/components'

--create, connect UI components

local App = {}
App.grid = include 'lib/lib-grvl/ui/grid'
App.arc = include 'lib/lib-grvl/ui/arc'
App.norns = include 'lib/ui/norns'

local x, y
do
    local top, bottom = 8, 64-2
    local left, right = 2, 128-2
    local mul = { x = (right - left) / 2, y = (bottom - top) / 2 }
    x = { left, left + mul.x*5/4, [1.5] = 24  }
    y = { top, bottom - 22, bottom, [1.5] = 20, }
end

-- function App.norns()
--     local _text = Screen.text()
    
--     -- local src_held = { 0, 0 }
--     -- local function set_active_src(v)
--     --     src_held = v

--     --     if src_held[1] > 0 then
--     --         grvl.active_src = patcher.sources[params:get('patcher_source_'..1)]
--     --     elseif src_held[2] > 0 then
--     --         grvl.active_src = patcher.sources[params:get('patcher_source_'..2)]
--     --     else
--     --         grvl.active_src = 'none'
--     --     end

--     --     crops.dirty.screen = true
--     --     crops.dirty.grid = true
--     --     crops.dirty.arc = true
--     -- end
--     -- local _active_src = Key.momentaries()

--     return function()
--         _text{ x = x[1], y = y[1], text = 'grvl' }
-Patcher.screen.destination(-         _text{ x = x[1], y = y[1] + 11*1, text = 'norns screen forthcoming' }
--         _text{ x = x[1], y = y[1] + 11*2, text = 'arc also forthcoming' }
--         _text{ x = x[1], y = y[1] + 11*3, text = 'have fun in the params menu' }
--         _text{ x = x[1], y = y[1] + 11*4, text = 'and on the grid' }

--         -- _active_src{
--         --     n = { 2, 3 },
--         --     state = crops.of_variable(src_held, set_active_src)
--         -- }
--     end
-- end

local map = { 
    { 'level_',      'old_',      'level_',      'old_'      },
    { 'pm_freq_',    'pm_depth_', 'pm_freq_',    'pm_depth_' },
    { 'loop_start_', 'loop_end_', 'loop_start_', 'loop_end_' },
    { 'loop_end_',   'rate_',     'loop_end_',   'rate_'     }
}

local _app = {
    grid = App.grid(),
    arc = App.arc{ 
        rotated = arc2,
        grid_wide = wide,
        map = map,
    },
    norns = App.norns{
        map = map,
    },
}

crops.connect_grid(_app.grid, g)
crops.connect_arc(_app.arc, a, 90)
crops.connect_screen(_app.norns, 15)
crops.connect_key(_app.norns)
crops.connect_enc(_app.norns)

--init/cleanup

function init()
    mod_src.lfos.reset_params()

    -- params:read()
    
    for i = 1,2 do mod_src.lfos[i]:start() end

    grvl.start_polls()
    params:bang()

    mod_src.init_crow()
end

function cleanup()
    poll.clear_all()
end
