--[[
    - Missing functions:
        - Refuel from fuel slot (don't know if fuel overflow is a real problem)
        - Reporting to a network could be handy
]]

--[[============================================================================
---             Constants
--============================================================================]]

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

--[[============================================================================
---         Types
---===========================================================================]]

---@alias Direction
---| 1 east / right
---| 2 south / down
---| 3 west / left
---| 4 north / up


---@class Position
---@field x integer
---@field y integer


---@class Node
---@field parent integer parent whilst searching
---@field edges integer[] references to neighbouring nodes
---@field position Position reletiv position to the starting point


---@class Graph
---@field nodes Node[]


---@class LastPoint
---@field position Position
---@field node integer

--[[===========================================================================
---         Functions
---==========================================================================]]

local function copy1(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[copy1(k)] = copy1(v) end
    return res
end

---@param graph Graph
---@param position Position
---@return Graph
local function findEdges(graph, position)
    local neighbours = {}
    for i = 1, 4, 1 do
        neighbours[i] = {
            x = position.x + DIRECTIONS[i].x,
            y = position.y + DIRECTIONS[i].y
        }
    end

    --- Check if neighbours exist in the graph
    local lastNode = #graph
    for i = 1, lastNode - 1, 1 do --- lastNode - 2 bacause no need to
        for j = 1, 4, 1 do
            if (graph[i].position.x == neighbours[j].x and graph[i].position.y == neighbours[j].y) then
                table.insert(graph[i].edges, lastNode)
                table.insert(graph[lastNode].edges, i)
            end
            --- Max number of neighbours
            if #graph[lastNode].edges == 4 then
                break
            end
        end
    end
    return graph
end

---@param graph Graph
---@param position Position
---@param lastNode integer
---@return Graph
local function addNodeToGraph(graph, position, lastNode)
    table.insert(graph, {
        position = position,
        edges = {}
    })
    graph = findEdges(graph, position)
    return graph
end

---Find best path from startNode to endNode in the given graph
---using the **A-Star** algorithm
---https://www.geeksforgeeks.org/a-search-algorithm/
---@param graph Graph
---@param startNode integer
---@param endNode integer
---@return integer[]
local function findPath(graph, startNode, endNode)
    --- Setup
    local graph_copy = copy1(graph)
    print("startNode", startNode, "targetNode", endNode)

    local open_list = {}
    local close_list = {}

    table.insert(open_list, startNode)

    graph_copy[startNode].f = 0
    graph_copy[startNode].g = 0

    -- for _, value in ipairs(graph_copy) do
    --     print(value.position.x, value.position.y, value.edges[1], value.edges[2], value.edges[3], value.edges[4])
    -- end

    while #open_list >= 1 do
        local min_f_value = 1000
        local min_f_index = nil
        for index_openList, value_openList in ipairs(open_list) do
            if graph_copy[value_openList].f < min_f_value then
                min_f_index = index_openList
                min_f_value = graph_copy[value_openList].f
            end
        end
        local q = table.remove(open_list, min_f_index)

        ---DEBUG
        -- print("Neben", graph_copy[q].edges[1], graph_copy[q].edges[2], graph_copy[q].edges[3], graph_copy[q].edges[4])

        for _, value_neighbour in ipairs(graph_copy[q].edges) do
            if value_neighbour == endNode then
                -- if #close_list < 1 then table.insert(close_list, 1, startNode) end
                table.insert(close_list, q)
                -- sleep(5)
                -- break
                return close_list
            end

            if not graph_copy[value_neighbour].isClosed then
                local new_g = graph_copy[q].g + 1
                local new_h = math.abs(graph_copy[value_neighbour].position.x - graph_copy[endNode].position.x) +
                    math.abs(graph_copy[value_neighbour].position.y - graph_copy[endNode].position.y)
                local new_f = new_g + new_h

                if graph_copy[value_neighbour].f == nil or graph_copy[value_neighbour].f > new_f then
                    graph_copy[value_neighbour].g = new_g
                    graph_copy[value_neighbour].h = new_h
                    graph_copy[value_neighbour].f = new_f
                end

                table.insert(open_list, value_neighbour)
            end
        end
        table.insert(close_list, q)
        graph_copy[q].isClosed = true
    end
    -- print("Target is not found")
    -- for index, value in ipairs(close_list) do
    --     print("Path", value)
    -- end
    -- sleep(10)

    table.insert(close_list, endNode)
    print("Target is found")
    for index, value in ipairs(close_list) do
        print("Path", value)
    end
    return close_list
end

--[[===========================================================================
---         Class VeinMiner
---==========================================================================]]

---@class VeinMiner
---@field private graph Graph
---@field private lastPoint LastPoint
---@field private direction Direction
---@field private rightTurnNodes integer[]


VeinMiner = {}

VeinMiner.graph = { {
    edges = {},
    position = {
        x = 0,
        y = 0
    }
} }

VeinMiner.lastPoint = {
    node = 1,
    position = {
        x = 0,
        y = 0
    }
}

VeinMiner.direction = 1

VeinMiner.rightTurnNodes = {}
table.insert(VeinMiner.rightTurnNodes, 1)


---@private
---@return nil
function VeinMiner:setupObsidianFarm()
    --- TODO
    --- Turtle stands on the Block in front of the ore
    --- Check Precondions: Fuel, Chest
    --- Place Chest
    --- Dig first Block and TurnLeft once
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

--- General function
---@private
---@param mineral listOfMinerals Mineral to look for
---@return nil
function VeinMiner:DigVein(mineral)
    while true do
        if VeinMiner:checkNode(mineral) then
            break
        end
    end
end

function VeinMiner:digObsidianLake()
    VeinMiner:setupObsidianFarm()
    local mineral = LIST_OF_MINERALS.obsidian
    while true do
        if VeinMiner:checkNode(mineral) then
            break
        end
    end
    --- TODO: Clean up and shutdown
    while VeinMiner.direction ~= 2 do
        VeinMiner:turnLeft()
    end
    turtle.up()
    turtle.forward()
    turtle.turnLeft()
    for i = 1, 16, 1 do
        turtle.select(i)
        turtle.drop()
    end
    print("Ich habe fertig!")
end

---@param mineral listOfMinerals
---@return boolean if back at starting positon
function VeinMiner:checkNode(mineral)
    --- Check right
    VeinMiner:turnRight()
    if not VeinMiner:checkAndDigDirection(mineral, true) then
        --- Check front
        VeinMiner:turnLeft()
        if not VeinMiner:checkAndDigDirection(mineral) then
            --- Check left
            VeinMiner:turnLeft()
            if not VeinMiner:checkAndDigDirection(mineral) then
                print("Last Node", VeinMiner.lastPoint.node)
                print("Last right turn", VeinMiner.rightTurnNodes[#VeinMiner.rightTurnNodes])
                -- sleep(5)
                if VeinMiner.lastPoint.node == VeinMiner.rightTurnNodes[#VeinMiner.rightTurnNodes] then
                    table.remove(VeinMiner.rightTurnNodes, #VeinMiner.rightTurnNodes)
                else
                    -- TODO check last right turn for neighbours
                    local path = findPath(VeinMiner.graph, VeinMiner.lastPoint.node,
                        VeinMiner.rightTurnNodes[#VeinMiner.rightTurnNodes])

                    table.insert(path, VeinMiner.rightTurnNodes[#VeinMiner.rightTurnNodes])
                    VeinMiner:followPath(path, mineral)
                    -- if VeinMiner:followPath(path, mineral) then
                    --     table.remove(VeinMiner.rightTurnNodes, #VeinMiner.rightTurnNodes)
                    -- end
                end
            end
        end
    end

    if #VeinMiner.rightTurnNodes < 1 then
        return true
    end
    return false
end

---@private
---@param mineral listOfMinerals
---@param right boolean?
---@return boolean
function VeinMiner:checkAndDigDirection(mineral, right)
    local has_block, data = turtle.inspect()
    if (has_block and data.name == mineral) then
        turtle.dig()
        if turtle.forward() then
            local new_positon = {
                x = VeinMiner.lastPoint.position.x + DIRECTIONS[VeinMiner.direction].x,
                y = VeinMiner.lastPoint.position.y + DIRECTIONS[VeinMiner.direction].y
            }

            --- Save last node
            if right then
                table.insert(VeinMiner.rightTurnNodes, VeinMiner.lastPoint.node)
            end

            --- Add node to graph
            VeinMiner.graph = addNodeToGraph(VeinMiner.graph, new_positon, VeinMiner.lastPoint.node)

            --- Update last point
            VeinMiner.lastPoint.position = new_positon
            VeinMiner.lastPoint.node = #VeinMiner.graph
            return true
        end
    end
    return false
end

---@private
---@param path integer[]
---@param mineral listOfMinerals
---@return nil | boolean
function VeinMiner:followPath(path, mineral)
    while #path >= 2 do
        VeinMiner:turnRight()
        if VeinMiner:checkAndDigDirection(mineral, true) then
            return false
        else
            VeinMiner:turnLeft()
        end

        local startNode = VeinMiner.graph[table.remove(path, 1)]
        local targetNode = VeinMiner.graph[path[1]]

        local direction = nil

        for i = 1, 4, 1 do
            if startNode.position.x + DIRECTIONS[i].x == targetNode.position.x and
                startNode.position.y + DIRECTIONS[i].y == targetNode.position.y then
                direction = i
            end
        end

        --- TODO: Optimize checking how to turn is faster than turning until
        --- direction is right
        while VeinMiner.direction ~= direction do
            VeinMiner:turnRight()
        end

        turtle.forward()
        local new_position = {
            x = VeinMiner.lastPoint.position.x + DIRECTIONS[VeinMiner.direction].x,
            y = VeinMiner.lastPoint.position.y + DIRECTIONS[VeinMiner.direction].y
        }
        VeinMiner.lastPoint.position = new_position
        VeinMiner.lastPoint.node = path[1]
    end
    return true
end

---@private
---@return nil
function VeinMiner:turnRight()
    turtle.turnRight()
    if VeinMiner.direction == 4 then
        VeinMiner.direction = 1
    else
        VeinMiner.direction = VeinMiner.direction + 1
    end
end

---@private
---@return nil
function VeinMiner:turnLeft()
    turtle.turnLeft()
    if VeinMiner.direction == 1 then
        VeinMiner.direction = 4
    else
        VeinMiner.direction = VeinMiner.direction - 1
    end
end

--[[===========================================================================
---         Main
---==========================================================================]]

local function Main()
    VeinMiner:digObsidianLake()
end

Main()
