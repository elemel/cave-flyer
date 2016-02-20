local Game = {}
Game.__index = Game

function Game.new(args)
    local game = setmetatable({}, Game)
    game:init(args)
    return game
end

function Game:init(args)
    -- Initialize registry

    self.categories = args.categories or {}
    self.registry = {}

    for i, category in ipairs(self.categories) do
        self.registry[category] = {}
    end

    -- Initialize update phases

    self.updatePhases = args.updatePhases or {}
    self.updateHandlers = {}

    for i, phase in ipairs(self.updatePhases) do
        self.updateHandlers[phase] = {}
    end

    -- Initialize draw phases

    self.drawPhases = args.drawPhases or {}
    self.drawHandlers = {}

    for i, phase in ipairs(self.drawPhases) do
        self.drawHandlers[phase] = {}
    end
end

function Game:register(entity, categories)
    for i, category in ipairs(categories) do
        self.registry[category][entity] = true
    end
end

function Game:deregister(entity, categories)
    for i, category in ipairs(categories) do
        self.registry[category][entity] = nil
    end
end

function Game:update(dt)
    for i, phase in ipairs(self.updatePhases) do
        for entity, handler in pairs(self.updateHandlers[phase]) do
            handler(entity, dt)
        end
    end
end

function Game:draw()
    for i, phase in ipairs(self.drawPhases) do
        for entity, handler in pairs(self.drawHandlers[phase]) do
            handler(entity)
        end
    end
end

return Game
