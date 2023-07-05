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

--@param level [integer[]]
--@return nil
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

local level2 = {
    { 0, 0, 0, 0, 0,  0,  0,  0, 0, 0 }, -- 01
    { 0, 0, 0, 0, 18, 17, 16, 0, 0, 0 }, -- 02
    { 0, 0, 0, 0, 19, 0,  15, 0, 0, 0 }, -- 03
    { 0, 0, 0, 0, 20, 13, 14, 0, 0, 0 }, -- 04
    { 0, 0, 0, 0, 0,  12, 0,  0, 0, 0 }, -- 05
    { 0, 0, 0, 0, 21, 11, 10, 0, 9, 0 }, -- 06
    { 0, 0, 0, 0, 22, 25, 5,  6, 7, 0 }, -- 07
    { 0, 0, 0, 0, 23, 24, 4,  0, 8, 0 }, -- 08
    { 0, 0, 0, 0, 1,  2,  3,  0, 0, 0 }, -- 09
    { 0, 0, 0, 0, 0,  0,  0,  0, 0, 0 } } -- 10
--   01,02,03,04,05,06,07,08,09,10

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




