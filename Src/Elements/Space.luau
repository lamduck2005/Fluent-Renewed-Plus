local Root = script.Parent.Parent
local Creator = require(Root.Modules.Creator)

local New = Creator.New

local Element = {}
Element.__index = Element
Element.__type = "Space"

function Element:New(Idx, Config)
    local Parent = self.Container or Creator.CurrentContainer
    
    local spaceHeight = 7 * (Config.Columns or 1)
    local spaceWidth = 7 * (Config.Columns or 1)
    
    local SpaceContainer = New("Frame", {
        Parent = Parent,
        LayoutOrder = Idx,
        BackgroundTransparency = 1,
    })
    
    if Config.ParentType ~= "Group" and not table.find({ "HStack", "VStack" }, Config.ParentType) then
        SpaceContainer.Size = UDim2.new(1, -8, 0, spaceHeight)
    elseif Config.ParentType == "Group" or table.find({ "HStack" }, Config.ParentType) then
        SpaceContainer.Size = UDim2.new(0, spaceWidth, 0, 0)
    else
        SpaceContainer.Size = UDim2.new(1, -8, 0, spaceHeight)
    end
    
    return { __type = "Space", ElementFrame = SpaceContainer }
end

return Element