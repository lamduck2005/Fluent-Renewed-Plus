local Root = script.Parent.Parent
local Creator = require(Root.Modules.Creator)

local New = Creator.New

local Element = {}
Element.__index = Element
Element.__type = "Divider"

function Element:New(Idx, Config)
    if typeof(Idx) == "table" and Config == nil then
        Config = Idx
        Idx = nil
    end
    Config = Config or {}
    local Parent = self.Container or Creator.CurrentContainer
    
    -- Create the separator line
    local DividerFrame = New("Frame", {
        Size = Config.ParentType ~= "Group" and UDim2.new(1, -8, 0, 2) or UDim2.new(0, 2, 1, -7),
        Position = Config.ParentType ~= "Group" and UDim2.new(0, 4, 0.5, 0) or UDim2.new(0.5, 0, 0, 4),
        AnchorPoint = Config.ParentType ~= "Group" and Vector2.new(0, 0.5) or Vector2.new(0.5, 0),
        BackgroundTransparency = 0.9,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Name = "DividerFrame",
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0, 1),
        })
    })
    
    -- Create container for padding
    local DividerContainer = New("Frame", {
        Parent = Parent,
        Size = Config.ParentType ~= "Group" and UDim2.new(1, 0, 0, 7) or UDim2.new(0, 7, 1, -7),
        BackgroundTransparency = 1,
        LayoutOrder = 7,
    }, {
        DividerFrame,
    })
    
    return { __type = "Divider", ElementFrame = DividerContainer }
end

return Element