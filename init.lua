local Game = {}

local CRYSTALS = {'A', 'B', 'C', 'D', 'E', 'F'}

local function crystal_new()
    return CRYSTALS[math.random(#CRYSTALS)]
end

function Game:new()
    self.__index = self
    return setmetatable({}, self)
end

function Game:init()
    self.field = {}
    for i = 0, 9 do
        self.field[i] = {}
        for j = 0, 9 do
            self.field[i][j] = crystal_new()
        end
    end
end

function Game:tick()
    local BOTTOM = 1
    local is_changes = false

    local matches = self:get_matches()
    if #matches > 0 then
        for _, cell in ipairs(matches) do
            self.field[cell[1]][cell[2]] = '~'
        end
        is_changes = true
    end

    for j = 0, 9 do
        local empty_cells = {}
        for i = 9, 0, -1 do
            if self.field[i][j] == '~' then
                table.insert(empty_cells, i)
            elseif #empty_cells > 0 then
                local botto_row = empty_cells[BOTTOM]
                self.field[botto_row][j] = self.field[i][j]
                self.field[i][j] = '~'
                table.remove(empty_cells, BOTTOM)
                table.insert(empty_cells, i)
                is_changes = true
            end
        end
    end

    for j = 0, 9 do
        for i = 0, 9 do
            if self.field[i][j] == '~' then
                self.field[i][j] = crystal_new()
                is_changes = true
            end
        end
    end

    return is_changes
end

function Game:get_matches()
    local matches = {}

    for i = 0, 9 do
        local count = 1
        for j = 1, 9 do
            if self.field[i][j] == self.field[i][j-1] then
                count = count + 1
            else
                if count >= 3 then
                    for k = j - count, j - 1 do
                        table.insert(matches, {i, k})
                    end
                end
                count = 1
            end
        end
        if count >= 3 then
            for k = 10 - count, 9 do
                table.insert(matches, {i, k})
            end
        end
    end

    for j = 0, 9 do
        local count = 1
        for i = 1, 9 do
            if self.field[i][j] == self.field[i-1][j] then
                count = count + 1
            else
                if count >= 3 then
                    for k = i - count, i - 1 do
                        table.insert(matches, {k, j})
                    end
                end
                count = 1
            end
        end
        if count >= 3 then
            for k = 10 - count, 9 do
                table.insert(matches, {k, j})
            end
        end
    end

    return matches
end

function Game:move(x, y, direction)
    x, y = tonumber(x) or 0, tonumber(y) or 0
    local newX, newY = x, y
    if direction == 'l' and y > 0 then newY = y - 1
    elseif direction == 'r' and y < 9 then newY = y + 1
    elseif direction == 'u' and x > 0 then newX = x - 1
    elseif direction == 'd' and x < 9 then newX = x + 1
    end
    if newX ~= x or newY ~= y then
        self.field[x][y], self.field[newX][newY] = self.field[newX][newY], self.field[x][y]
        return true
    end
    print("Неверные координаты!")
    return false
end

function Game:mix()
    for i = 0, 9 do
        for j = 0, 9 do
            self.field[i][j] = crystal_new()
        end
    end
    while true do
        local changed = self:tick()
        if not changed then break end
    end
end

function Game:dump()
    print(table.concat({'  |',0,1,2,3,4,5,6,7,8,9}, ' '))
    print(string.rep('-', 23))
    for i = 0, 9 do
        local row = {}
        for j = 0, 9 do
            table.insert(row, self.field[i][j])
        end
        print(i .. ' | ' .. table.concat(row, ' '))
    end
end

local game = Game:new()
game:init()

while true do
    game:dump()
    local input = io.read("*l")
    if input == "q" then
        break
    end

    local cmd, x, y, direction = input:match("(%w+)%s*(%d)%s*(%d)%s*(%a)")
    if cmd == "m" and x and y and direction then
        if game:move(x, y, direction) then
            while true do
                local changed = game:tick()
                if not changed then break end
            end
        end
    elseif input == "mix" then
        game:mix()
    else
        print("Неверная команда!")
    end
end
