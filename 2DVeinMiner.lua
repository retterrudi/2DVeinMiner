--[[===========================================================================
---             Constants
--===========================================================================]]

---@enum listOfMinerals
local LIST_OF_MINERALS = {
    obsidian = "minecraft:obsidian"
}


---@enum inventory_slots
local INVENTORY_SLOTS = {
    FUEL_SLOT = 14,
    CHEST_SLOT = 15,
    TORCH_SLOT = 16
}

local DIRECTIONS = {
    { x = 1,  y = 0 },
    { x = 0,  y = -1 },
    { x = -1, y = 0 },
    { x = 0,  y = 1 },
}

--[[===========================================================================
---         Types
---==========================================================================]]

---@alias Direction
---| 1 east / right
---| 2 south / down
---| 3 west / left
---| 4 north / up

---@class Position
---@field x integer
---@field y integer

---@class Node
---@field position Position Reletiv position to the starting point
---@field edges integer[] Unordered list of indeces of neighbouring nodes
---@field g_value number Cost to reach this node
---@field h_value number Cost to target node (distance)
---@field f_value number Final cost for this node
---@field isClosed boolean

---@class Graph
---@field nodes Node[]

---@class LastPoint
---@field position Position
---@field node integer

--[[===========================================================================
---         Functions
---==========================================================================]]

local function copyTable(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[copyTable(k)] = copyTable(v) end
    return res
end

---@param level table[]
---@return nil
local function printLevel(level)
    for _, row in ipairs(level) do
        local rowString = ""

        for _, entry in ipairs(row) do
            local placeholder = nil

            if entry == 0 then
                placeholder = " "
            else
                placeholder = entry
            end

            rowString = rowString .. placeholder
        end

        print(rowString)
    end
end

---@param graph Graph
---@return nil
local function printGraph(graph)
    for _, node in ipairs(graph) do
        print(
            node.position.x,
            node.position.y,
            node.edges[1],
            node.edges[2],
            node.edges[3],
            node.edges[4]
        )
    end
end

--@param graph Graph
--@param startNode integer
--@param endNode integer
local function findPath(graph, startNode, endNode)
    local copiedGraph = copyTable(graph)

    local openList = {}
    local closeList = {}

    table.insert(openList, startNode)


    copiedGraph[startNode].f = 0
    copiedGraph[startNode].g = 0

    while #openList >= 1 do
        local minFValue = 1000
        local minFIndex = nil
        --DEBUG
        print("OpenList:")
        for _, value in ipairs(openList) do
            local cost = 'nil'
            if copiedGraph[value].f ~= nil then
                cost = copiedGraph[value].f
            end
            print('Node: ' .. value .. ' Cost: ' .. cost)
        end
        print("CloseList:")
        for _, value in ipairs(closeList) do
            local cost = 'nil'
            if copiedGraph[value].f ~= nil then
                cost = copiedGraph[value].f
            end
            print('Node: ' .. value .. ' Cost: ' .. cost)
        end

        -- find node with lowest f in openList
        for indexOpenList, valueOpenList in ipairs(openList) do
            if copiedGraph[valueOpenList].f < minFValue then
                minFIndex = indexOpenList
                minFValue = copiedGraph[valueOpenList].f
            end
        end

        local q =  table.remove(openList, minFIndex)

        for _, valueNeighbour in ipairs(copiedGraph[q].edges) do
            if valueNeighbour == endNode then
                table.insert(closeList, q)
                return closeList
            end

            local newG = copiedGraph[q].g + 1
            local newH = math.abs(copiedGraph[valueNeighbour].position.x - copiedGraph[endNode].position.x) +
               math.abs(copiedGraph[valueNeighbour].position.y - copiedGraph[endNode].position.y)
            local newF = newG + newH

            local skip = false
            for _, value in ipairs(openList) do
                if value == valueNeighbour then
                    if newF >= copiedGraph[valueNeighbour].f then
                        skip = true
                    end
                end
            end

            if not copiedGraph[valueNeighbour].isClosed or skip then
                table.insert(openList, valueNeighbour)
                copiedGraph[valueNeighbour].g = newG
                copiedGraph[valueNeighbour].h = newH
                copiedGraph[valueNeighbour].f = newF
            else
                if copiedGraph[valueNeighbour].f > newF then
                    copiedGraph[valueNeighbour].g = newG
                    copiedGraph[valueNeighbour].h = newH
                    copiedGraph[valueNeighbour].f = newF
                end
            end
        end

        table.insert(closeList, q)
        copiedGraph[q].isClosed = true
    end

    table.insert(closeList, endNode)
    return closeList
end


--[[===========================================================================
---         Example
---==========================================================================]]

local level1 = {
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},  -- 01
    { 0, 0, 0, 0, 1, 1, 1, 0, 0, 0},  -- 02
    { 0, 0, 0, 0, 1, 0, 1, 0, 0, 0},  -- 03
    { 0, 0, 0, 0, 1, 1, 1, 0, 0, 0},  -- 04
    { 0, 0, 0, 0, 0, 1, 0, 0, 0, 0},  -- 05
    { 0, 0, 0, 0, 1, 1, 1, 0, 1, 0},  -- 06
    { 0, 0, 0, 0, 1, 1, 1, 1, 1, 0},  -- 07
    { 0, 0, 0, 0, 1, 1, 1, 0, 1, 0},  -- 08
    { 0, 0, 0, 0, 1, 1, 1, 0, 0, 0},  -- 09
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} } -- 10
--   01,02,03,04,05,06,07,08,09,10

--- level1 node numbered
local level2 = {
    { 0, 0, 0, 0, 0,  0,  0,  0, 0, 0 },  -- 01
    { 0, 0, 0, 0, 18, 17, 16, 0, 0, 0 },  -- 02
    { 0, 0, 0, 0, 19, 0,  15, 0, 0, 0 },  -- 03
    { 0, 0, 0, 0, 20, 13, 14, 0, 0, 0 },  -- 04
    { 0, 0, 0, 0, 0,  12, 0,  0, 0, 0 },  -- 05
    { 0, 0, 0, 0, 21, 11, 10, 0, 9, 0 },  -- 06
    { 0, 0, 0, 0, 22, 25, 5,  6, 7, 0 },  -- 07
    { 0, 0, 0, 0, 23, 24, 4,  0, 8, 0 },  -- 08
    { 0, 0, 0, 0, 1,  2,  3,  0, 0, 0 },  -- 09
    { 0, 0, 0, 0, 0,  0,  0,  0, 0, 0 } } -- 10
--   01,02,03,04,05, 06, 07, 08,09,10

local exampleGraph = {
    { position = { x = 0, y = 0 }, edges = { 2, 23 } },          -- 01
    { position = { x = 1, y = 0 }, edges = { 1, 3, 24 } },       -- 02
    { position = { x = 2, y = 0 }, edges = { 2, 4 } },           -- 03
    { position = { x = 2, y = 1 }, edges = { 3, 5, 24 } },       -- 04
    { position = { x = 2, y = 2 }, edges = { 4, 6, 10, 25 } },   -- 05
    { position = { x = 3, y = 2 }, edges = { 5, 7 } },           -- 06
    { position = { x = 4, y = 2 }, edges = { 6, 8, 9 } },        -- 07
    { position = { x = 4, y = 1 }, edges = { 7 } },              -- 08
    { position = { x = 4, y = 3 }, edges = { 7 } },              -- 09
    { position = { x = 2, y = 3 }, edges = { 5, 11 } },          -- 10
    { position = { x = 1, y = 3 }, edges = { 10, 12, 21, 25 } }, -- 11
    { position = { x = 1, y = 4 }, edges = { 11, 13 } },         -- 12
    { position = { x = 1, y = 5 }, edges = { 12, 14, 20 } },     -- 13
    { position = { x = 2, y = 5 }, edges = { 13, 15 } },         -- 14
    { position = { x = 2, y = 6 }, edges = { 14, 16 } },         -- 15
    { position = { x = 2, y = 7 }, edges = { 15, 17 } },         -- 16
    { position = { x = 1, y = 7 }, edges = { 16, 18 } },         -- 17
    { position = { x = 0, y = 7 }, edges = { 17, 19 } },         -- 18
    { position = { x = 0, y = 6 }, edges = { 18, 20 } },         -- 19
    { position = { x = 0, y = 5 }, edges = { 19, 13 } },         -- 20
    { position = { x = 0, y = 3 }, edges = { 11, 22 } },         -- 21
    { position = { x = 0, y = 2 }, edges = { 21, 23, 25 } },     -- 22
    { position = { x = 0, y = 1 }, edges = { 22, 1, 24 } },      -- 23
    { position = { x = 1, y = 1 }, edges = { 23, 2, 4, 25 } },   -- 24
    { position = { x = 1, y = 2 }, edges = { 24, 5, 11, 22 } },  -- 25
}

--[[===========================================================================
---         Main
---==========================================================================]]

function Main()
    local path = findPath(exampleGraph, 1, 16)
    for index, value in ipairs(path) do
        print(index .. ' ' .. value)
    end
end

Main()
