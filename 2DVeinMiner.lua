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

local function copyTable(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[copyTable(k)] = copyTable(v) end
    return res
end

--[[===========================================================================
---         Example
---==========================================================================]]

local map = {
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},  -- 01
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},  -- 02
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},  -- 03
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},  -- 04
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},  -- 05
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},  -- 06
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},  -- 07
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},  -- 08
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},  -- 09
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} } -- 10
--   01,02,03,04,05,06,07,08,09,10





