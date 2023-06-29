--[[
- 1 hit dead end
- 2 build graph to last turn right
  - calculate distance to target node
  - calculate all neighbours
  - for each neighbour check if in
- 3 calculate shortest path using A*
- 4 move on path and keep checking left
  - if ore left dig until dead end and repeat
  - else move till end
    - if no ore found pop last turn right go to last turn right
    - else dig
- 5 if last turn right was start move to chest
]]

--- Locals

---@enum listOfMinerals
local LIST_OF_MINERALS = {
  obsidian = "minecraft:obsidian"
}



local DIRECTIONS = {
  { x = 0,  y = 1 },
  { x = 0,  y = -1 },
  { x = -1, y = 0 },
  { x = 1,  y = 0 }
}

---============================================================================
---         Types
---============================================================================

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

---============================================================================
---         Functions
---============================================================================

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
  for i = 1, lastNode - 1, 1 do
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
    edges = { lastNode }
  })
  graph = findEdges(graph, position)
  return graph
end

---============================================================================
---         Class VeinMiner
---============================================================================

---@class VeinMiner
---@field private graph Graph
---@field private lastPoint LastPoint
---@field private direction Direction


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

VeinMiner.direction = 0


---@private
---@return nil
function VeinMiner.setup()
  --- Turtle stands on the Block in front of the ore
  --- Check Precondions: Fuel, Chest
  --- Place Chest
  --- Dig first Block and TurnLeft once
end

---@private
---@param mineral listOfMinerals Mineral to look for
---@return nil
function VeinMiner:DigVein(mineral)
  --- Check right
  VeinMiner:turnRight()
  local has_block, data = turtle.inspect()
  if (has_block and data.name == mineral) then
    turtle.dig()
    if turtle.forward() then
      local new_positon = {
        x = VeinMiner.lastPoint.position.x + DIRECTIONS[VeinMiner.direction].x,
        y = VeinMiner.lastPoint.position.y + DIRECTIONS[VeinMiner.direction].y
      }

      --- Add node to graph
      VeinMiner.graph = addNodeToGraph(VeinMiner.graph, new_positon, VeinMiner.lastPoint.node)

      --- Update last point
      VeinMiner.lastPoint.position = new_positon
      VeinMiner.lastPoint.node = #VeinMiner.graph
    end
  end

  --- TODO: Save point of last turn right

  --- Check Front
  VeinMiner:turnLeft()
  --- Call Dig function

  --- Check Right
  VeinMiner:turnLeft()
  --- Call Dig function

  --- If reached ... go back to last point of turning right
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

---============================================================================
---       Main
---============================================================================

local function Main()
  VeinMiner:DigVein(LIST_OF_MINERALS.obsidian)
end

Main()
