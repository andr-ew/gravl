--add source & destination params
do
    params:add_separator('patcher')

    for i = 1,2 do
        params:add{
            id = 'patcher_source_'..i, name = 'source '..i,
            type = 'option', options = patcher.src_names,
            default = tab.key(patcher.sources, 'crow_in_'..i)
        }
    end
    for i = 3,4 do
        params:add{
            id = 'patcher_source_'..i, name = 'source '..i,
            type = 'option', options = patcher.src_names,
            default = tab.key(patcher.sources, 'lfo_'..(i-2))
        }
    end

    local function action(dest, v)
        crops.dirty.grid = true
        crops.dirty.screen = true
        crops.dirty.arc = true
    end

    params:add_group('assignments', #patcher.destinations)
    patcher.add_assignment_params(action)
end
