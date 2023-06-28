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

---@enum direction
local DIRECTIONS = {
    north = { 0,  1},
    east  = { 1,  0},
    south = { 0, -1},
    west  = {-1,  0}
}

---@class Position
---@field x integer
---@field y integer


---@class VeinMiner
---@field private positions Position[]
local VeinMiner = {}

VeinMiner.positions = {
    {x = 0, y = 0}
}

---@private
---@param mineral listOfMinerals Mineral to look for
---@return nil
function VeinMiner:DigVein(mineral)
    --- here comes the fun :)
    local a = #VeinMiner.positions
end


--- Main
local function Main()
    VeinMiner:DigVein(LIST_OF_MINERALS.obsidian)
end

Main()