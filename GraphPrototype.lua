local DIRECTIONS = {
    {x = 1, y = 0},
    {x = 0, y = 1},
    {x = -1, y = 0},
    {x = 0, y = -1}
}

local Graph = {
}

table.insert(Graph, {edges = {2},
                     position = {x = 0,
                                 y = 0}})

table.insert(Graph, {edges = {1},
                     position = {x = 1,
                                 y = 0}})


---@param position Position
---@return Position[]
local function findNeighbours(position)
    local neighbours = {}
    for i = 1, 4, 1 do --- for var = start, stop, step do where stop is inclusive
         table.insert(neighbours, {x = (position.x + DIRECTIONS[i].x), y = (position.y + DIRECTIONS[i].y)})
    end
    return neighbours
 end

print(findNeighbours({x = 1, y = 0})[1].x)