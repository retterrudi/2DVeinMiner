local depth = 0
local selected = 1

turtle.select(1)

while turtle.down() do
    depth = depth + 1
end

for _ = 1, 4, 1 do
    turtle.up()
    depth = depth - 1
end

while depth > 0 do
    if 0 == turtle.getItemCount() then
        selected = selected + 1
        turtle.select(selected)
    end

    turtle.place()
    turtle.up()
    depth = depth - 1
end