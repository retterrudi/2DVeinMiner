local isOnWayBack = false
local backwardsCounter = 0

function CheckLeft()
    turtle.turnLeft()
    local success, data = turtle.inspect()
    if success then
        if data.name == "minecraft:obsidian" then
            DigForward()
        else
            CheckFront()
        end
    else
        if isOnWayBack then
            GoForward()
        else
            CheckFront()
        end
    end
end


function CheckFront()
    turtle.turnRight()
    local success, data = turtle.inspect()
    if success then
        if data.name == "minecraft:obsidian" then
            DigForward()
        else
            CheckRight()
        end
    else
        if isOnWayBack  then
            GoForward()
        else            
            CheckRight()
        end
    end
end


function CheckRight()
    turtle.turnRight()
    local success, data = turtle.inspect()
    if success then
        if data.name == "minecraft:obsidian" then
            DigForward()
        else
            turtle.turnLeft()
            TurnAround()
        end
    else
        if isOnWayBack then
            GoForward()
        else
            turtle.turnLeft()
            TurnAround()
        end
    end
end

function DigForward()
    isOnWayBack = false
    backwardsCounter = 0
    turtle.dig()
    turtle.forward()
    CheckLeft()
end

function TurnAround()
    isOnWayBack = true
    turtle.turnRight(2)
    turtle.forward()
    CheckLeft()
end

function GoForward()
    backwardsCounter = backwardsCounter + 1
    if backwardsCounter == 10 then
        turtle.digUp()
        turtle.up()
        return 0
    end
    turtle.forward()
    CheckLeft()
end


function Main()
	turtle.digDown()
	turtle.down()
    CheckLeft()
end

Main()

