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

---@class Position2D
---@field x integer
---@field y integer

---@class Node
---@field position Position2D Reletiv position to the starting point
---@field edges integer[] Unordered list of indeces of neighbouring nodes
---@field g_value number Cost to reach this node
---@field h_value number Cost to target node (distance)
---@field f_value number Final cost for this node
---@field isClosed boolean

---@class Graph
---@field nodes Node[]

---@class LastPoint
---@field position Position2D
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

---@param graph Graph
---@param startNode integer Index of start node
---@param endNode integer Index of target node
---@return integer[]
local function createPathFromGraph(graph, startNode, endNode)
    local nodes = {startNode, endNode}
    local currentNode = endNode
    while true do
        if graph[currentNode].parent == startNode then
            return nodes
        else
            currentNode = graph[currentNode].parent
            table.insert(nodes, 2, currentNode)
        end
    end
end

---@param graph Graph
---@param startNode integer Starting node in the graph
---@param endNode integer Target node in the graph
---@return integer[] path Path consisting of nodes in a graph
local function aStarPathFinder(graph, startNode, endNode)
    local copiedGraph = copyTable(graph)

    local openList = {}
    local closeList = {}

    table.insert(openList, startNode)

    copiedGraph[startNode].f = 0
    copiedGraph[startNode].g = 0
    copiedGraph[startNode].parent = nil

    while #openList >= 1 do
        -- find node with most low f in openList
        -- prever lower g over lower h
        local minFValue = 10000000
        local minFIndex = nil

        local lowCostTable = {}     -- holds all values that where at some 
                                    -- point lower than the minFValue

        for openListIndex, openListValue in ipairs(openList) do
            if copiedGraph[openListValue].f <= minFValue then
                table.insert(
                    lowCostTable,
                    {index = openListIndex, node = openListValue})
                minFValue = copiedGraph[openListValue].f
            end
        end

        local minGValue = 10000000
        for _, valueLowCostTable in ipairs(lowCostTable) do
            if copiedGraph[valueLowCostTable.node].f == minFValue then
                if copiedGraph[valueLowCostTable.node].g < minGValue then
                    minGValue = copiedGraph[valueLowCostTable.node].g
                    minFIndex = valueLowCostTable.index
                end
            end
        end

        local q = table.remove(openList, minFIndex)

        for _, nodeNeighbour in ipairs(copiedGraph[q].edges) do

            -- Check for destination
            if nodeNeighbour == endNode then
                copiedGraph[endNode].parent = q
                return createPathFromGraph(copiedGraph, startNode, endNode)
            end

            -- Calculate new cost
            local newG = copiedGraph[q].g + 1
            local newH = math.abs(copiedGraph[nodeNeighbour].position.x - copiedGraph[endNode].position.x) +
               math.abs(copiedGraph[nodeNeighbour].position.y - copiedGraph[endNode].position.y)
            local newF = newG + newH

            -- Check openList
            local skip = false
            for _, valueOpenList in ipairs(openList) do
                if valueOpenList == nodeNeighbour then
                    if copiedGraph[nodeNeighbour].f < newF or
                        (copiedGraph[nodeNeighbour].f == newF and copiedGraph[nodeNeighbour].g < newG) then

                        skip = true
                    end
                end
            end

            if not (skip or copiedGraph[nodeNeighbour].isClosed) then
                copiedGraph[nodeNeighbour].f = newF
                copiedGraph[nodeNeighbour].g = newG
                copiedGraph[nodeNeighbour].h = newH
                copiedGraph[nodeNeighbour].parent = q
                table.insert(openList, nodeNeighbour)
            end
            table.insert(closeList, q)
            copiedGraph[q].isClosed = true
        end
    end
    return createPathFromGraph(copiedGraph, startNode, endNode)
end

---@param graph Graph
---@param position Position2D Position of the new Node (of which to find the edges of existing nodes)
---@return Graph
local function addNewEdges(graph, position)
    local neighbours = {}
    for i = 1, 4, 1 do
        neighbours[i] = {
            x = position.x + DIRECTIONS[i].x,
            y = position.y + DIRECTIONS[i].y
        }
    end

    local lastNode = #graph
    for i = 1, lastNode - 1, 1 do
        for j = 1, 4, 1 do
            if (graph[i].position.x == neighbours[j].x and graph[i].position.y == neighbours[j].y) then
                table.insert(graph[i].edges, lastNode)
                table.insert(graph[lastNode].edges, i)
            end

            if #graph[lastNode].edges == 4 then
                break
            end
        end
    end
    return graph
end

---@param graph Graph
---@param position Position2D Position of the new node
---@return Graph
local function addNodeToGraph(graph, position)
    table.insert(graph, {
        position = position,
        edges = {}
    })
    graph = addNewEdges(graph, position)
    return graph
end

--[[===========================================================================
---         Class: Miner
---==========================================================================]]

---@class Miner
---@field graph Graph
---@field lastPoint {node: integer, position: Position2D}
---@field direction Direction
---@field rightTurnNodes integer[]
local Miner = {}

-- Miner.graph = {{
--     edges = {},
--     position = {
--         x = 0,
--         y = 0
--     }
-- }}

Miner.lastPoint = {
    node = 1,
    position = {
        x = 0,
        y = 0
    }
}

Miner.direction = 1

Miner.rightTurnNodes = {}
table.insert(Miner.rightTurnNodes, 1)

---@private
function Miner:TurnRight()
    turtle.turnRight()
    if Miner.direction == 4 then
        Miner.direction = 1
    else
        Miner.direction = Miner.direction + 1
    end
end

---@private
function Miner:TurnLeft()
    turtle.turnLeft()
    if Miner.direction == 1 then
        Miner.direction = 4
    else
        Miner.direction = Miner.direction - 1
    end
end

---@private
function Miner:SetupObsidianFarm()
    turtle.turnRight()
    turtle.select(INVENTORY_SLOTS.CHEST_SLOT)
    turtle.place()
    turtle.select(1)
    turtle.turnLeft()
    turtle.forward()
    turtle.digDown()
    turtle.down()
    turtle.turnRight()
end

---@private
---@param mineral listOfMinerals
---@param right boolean?
---@return boolean
function Miner:CheckAndDigDirection(mineral, right)
    local hasBlock, data = turtle.inspect()
    if (hasBlock and data.name == mineral) then
        turtle.dig()
        if turtle.forward() then
            local newPosition = {
                x = Miner.lastPoint.position.x + DIRECTIONS[Miner.direction].x,
                y = Miner.lastPoint.position.y + DIRECTIONS[Miner.direction].y,
            }

            if right then
                table.insert(Miner.rightTurnNodes, Miner.lastPoint.node)
            end

            Miner.graph = addNodeToGraph(Miner.graph, newPosition)

            Miner.lastPoint.position = newPosition
            Miner.lastPoint.node = #Miner.graph
            return true
        end
    end
    return false
end

---@private
---@param path integer[] List of node indeces defining a path
---@param mineral listOfMinerals
---@return boolean
function Miner:FollowPath(path, mineral)
    while #path >= 2 do
        Miner:TurnRight()
        if Miner:CheckAndDigDirection(mineral, true) then
            return false
        else
            Miner:TurnLeft()
        end

        local startNode = Miner.graph[table.remove(path, 1)]
        local targetNode = Miner.graph[path[1]]

        local direction = nil

        for i = 1, 4, 1 do
            if startNode.position.x + DIRECTIONS[i].x == targetNode.position.x and
                startNode.position.y + DIRECTIONS[i].y == targetNode.position.y then
                direction = i
            end
        end

        while Miner.direction ~= direction do
            Miner:TurnRight()
        end

        turtle.forward()
        local newPosition = {
            x = Miner.lastPoint.position.x + DIRECTIONS[Miner.direction].x,
            y = Miner.lastPoint.position.y + DIRECTIONS[Miner.direction].y
        }
        Miner.lastPoint.position = newPosition
        Miner.lastPoint.node = path[1]
    end
    return true
end

---@private
---@param mineral listOfMinerals
---@return boolean
function Miner:CheckNode(mineral)
    -- Check right
    Miner:TurnRight()
    if not Miner:CheckAndDigDirection(mineral, true) then
        -- Check front
        Miner:TurnLeft()
        if not Miner:CheckAndDigDirection(mineral) then
            -- Check left
            Miner:TurnLeft()
            if not Miner:CheckAndDigDirection(mineral) then
                if Miner.lastPoint.node == Miner.rightTurnNodes[#Miner.rightTurnNodes] then
                    table.remove(Miner.rightTurnNodes, #Miner.rightTurnNodes)
                else
                    local path = aStarPathFinder(
                        Miner.graph,
                        Miner.lastPoint.node,
                        Miner.rightTurnNodes[#Miner.rightTurnNodes])

                    if Miner:FollowPath(path, mineral) then
                        table.remove(Miner.rightTurnNodes, #Miner.rightTurnNodes)
                    end
                end
            end
        end
    end

    if #Miner.rightTurnNodes < 1 then
        return true
    else
        return false
    end
end

function Miner:DigObsidianLake()
    Miner:SetupObsidianFarm()
    local mineral = LIST_OF_MINERALS.obsidian
    while true do
        if Miner:CheckNode(mineral) then
            break
        end
    end

    while Miner.direction ~= 2 do
        Miner:TurnLeft()
    end
    turtle.up()
    turtle.forward()
    turtle.turnLeft()
    for i = 1, 16, 1 do
        turtle.select(i)
        turtle.drop()
    end
    print("Ich habe fertig")
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
    Miner:DigObsidianLake()
end

Main()
