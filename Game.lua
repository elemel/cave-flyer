local Game = {}
Game.__index = Game

function Game.new(args)
    local game = setmetatable({}, Game)
    game:init(args)
    return game
end

function Game:init(args)
    -- Initialize registry

    self.tags = args.tags or {}
    self.registry = {}

    for i, tag in ipairs(self.tags) do
        self.registry[tag] = {}
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

function Game:register(entity, tags)
    for i, tag in ipairs(tags) do
        self.registry[tag][entity] = true
    end
end

function Game:deregister(entity, tags)
    for i, tag in ipairs(tags) do
        self.registry[tag][entity] = nil
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
