-- grvl
--
-- dual data pavement
--
-- version 0.3.0 @andrew
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

--create UI components

local App = {}
App.grid = include 'lib/lib-grvl/ui/grid'
App.arc = include 'lib/lib-grvl/ui/arc'
App.norns = include 'lib/ui/norns'

--more globals

local x, y
do
    local top, bottom = 8, 64-2
    local left, right = 2, 128-2
    local mul = { x = (right - left) / 2, y = (bottom - top) / 2 }
    x = { left, left + mul.x*5/4, [1.5] = 24  }
    y = { top, bottom - 22, bottom, [1.5] = 20, }
end

--connect UI components

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
