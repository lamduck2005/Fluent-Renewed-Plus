local Root = script.Parent.Parent
local Creator = require(Root.Modules.Creator)

local New = Creator.New

local Element = {}
Element.__index = Element
Element.__type = "Space"

function Element:New(Idx, Config)
    if typeof(Idx) == "table" and Config == nil then
        Config = Idx
        Idx = nil
    end
    Config = Config or {}
    local Parent = self.Container or Creator.CurrentContainer
    
    local columns = Config.Column or Config.Columns or 3
    local spaceHeight = 7 * columns
    local spaceWidth = 7 * columns
    
    local SpaceContainer = New("Frame", {
        Parent = Parent,
        LayoutOrder = 7,
        BackgroundTransparency = 1,
    })
    
    if Config.ParentType ~= "Group" and not table.find({ "HStack", "VStack" }, Config.ParentType) then
        SpaceContainer.Size = UDim2.new(1, 0, 0, spaceHeight)
    elseif Config.ParentType == "Group" or table.find({ "HStack" }, Config.ParentType) then
        SpaceContainer.Size = UDim2.new(0, spaceWidth, 0, 0)
    else
        SpaceContainer.Size = UDim2.new(1, 0, 0, spaceHeight)
    end
    
    return { __type = "Space", ElementFrame = SpaceContainer }
end

return Element