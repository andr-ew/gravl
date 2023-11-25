--add LFO params
for i = 1,2 do
    params:add_separator('lfo '..i)
    mod_src.lfos[i]:add_params('lfo_'..i)
end

--add source & destination params
do
    params:add_separator('patcher sources')

    for i = 1,2 do
        params:add{
            id = 'patcher_source_'..i, name = 'source '..i,
            type = 'option', options = patcher.sources,
            default = tab.key(patcher.sources, 'crow in '..i)
        }
    end
    for i = 3,4 do
        params:add{
            id = 'patcher_source_'..i, name = 'source '..i,
            type = 'option', options = patcher.sources,
            default = tab.key(patcher.sources, 'lfo '..(i-2))
        }
    end

    local function action(dest, v)
        mod_src.crow.update()

        crops.dirty.grid = true
        crops.dirty.screen = true
        crops.dirty.arc = true
    end

    params:add_separator('patcher assignments')

    patcher.add_assginment_params(action)
end
