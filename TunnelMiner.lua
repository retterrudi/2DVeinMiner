local COBBLESTONE_SLOT = 15
local TORCH_SLOT = 16
local layernumber = 0

function ReturnHome()
    turtle.turnLeft()
	turtle.turnLeft()
	for i = 1, 32 do
		turtle.forward()
	end
end

function DigLayer()
    DigBottomLayer()
    DigTopTwoLayers()
    layernumber = layernumber + 1
end

function DigBottomLayer()
    DigStepBottomLayer()
    turtle.turnLeft()
    DigStepBottomLayer()
    DigStepBottomLayer()
    turtle.turnRight()
end

function DigStepBottomLayer()
    while turtle.dig() do
        os.sleep(0.5)
    end
    turtle.forward()
    if 	not turtle.detectDown() then
        turtle.select(COBBLESTONE_SLOT)
        turtle.placeDown()
    end
end

function DigTopTwoLayers()
    while turtle.digUp() do
        os.sleep(0.5)
    end
    turtle.up()
    while turtle.digUp() do
        os.sleep(0.5)
    end
    turtle.turnRight()
    while turtle.dig() do
        os.sleep(0.5)
    end
    turtle.forward()
    while turtle.dig() do
        os.sleep(0.5)
    end
    while turtle.digUp() do
        os.sleep(0.5)
    end
    PlaceTorch()
    turtle.forward()
    turtle.turnLeft()
    while turtle.digUp() do
        os.sleep(0.5)
    end
    turtle.down()
end

function PlaceTorch()
    if layernumber % 4 == 0 then
        turtle.turnLeft()
        turtle.turnLeft()
        turtle.select(TORCH_SLOT)
        turtle.place()
        turtle.turnRight()
        turtle.turnRight()
    end
end

function CheckForGravelFront()
    local success, data = turtle.inspect()
    if success then
        if data.name == "minecraft:gravel" then
            turtle.dig()
        end
    end
end

function Main()
    for i = 1, 32, 1 do
        DigLayer()
    end
	ReturnHome()
end

Main()
