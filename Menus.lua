-- FormFreedom: independently named standalone adaptation; see README.md and LICENSE.md.
local _, ab = ...
if not ab.enabled then return end
-- Hardware-click form cancellation for the stock taxi map and Warstorm's book.
-- Detached secure children avoid protecting Blizzard's movable panel ancestors.
local host = CreateFrame('Frame', 'FormFreedomMenuHost', UIParent, 'SecureHandlerStateTemplate')
RegisterStateDriver(host, 'visibility', '[combat] hide; show')
local overlays, pendingBook, bookOpen = {}, nil, false
local refreshGeneration = 0
local reconcileAt
local function ItemID(value)
    if type(value) == 'number' then return value end
    if type(value) ~= 'string' then return end
    return tonumber(value:match('item:(%d+)')) or tonumber(value)
end
local function MarkBook(value)
    local id = ItemID(value)
    if not id and value and GetItemInfo then
        local _, link = GetItemInfo(value)
        id = ItemID(link)
    end
    if id == 9017 then pendingBook = GetTime() end
end
hooksecurefunc('UseContainerItem', function(bag, slot) MarkBook(GetContainerItemLink(bag, slot)) end)
hooksecurefunc('UseItemByName', MarkBook)
hooksecurefunc('UseAction', function(slot)
    local kind, id = GetActionInfo(slot)
    if kind == 'item' then MarkBook(id) end
end)
local function ReleaseMouseHover(button)
    local original = button.hoveredSource
    button.hoveredSource = nil
    if original then
        original:UnlockHighlight()
        local script = original:GetScript('OnLeave')
        if script then script(original) end
    end
end
local function HideOverlay(button)
    ReleaseMouseHover(button)
    if button.source and button.source.ffAutoFormClick == button then
        button.source.ffAutoFormClick = nil
    end
    button.source = nil
    button:Hide()
end
local function Place(key, source, macro, craftClick)
    local button = overlays[key]
    if not button then
        button = CreateFrame('Button', 'FormFreedomMenu'..key, host, 'SecureActionButtonTemplate')
        button.ignoreNode = true
        button:RegisterForClicks('LeftButtonUp')
        button:SetAttribute('type', 'macro')
        button:SetScript('OnEnter', function(self)
            local original = self.source
            if original then
                self.hoveredSource = original
                original:LockHighlight()
                local script = original:GetScript('OnEnter')
                if script then script(original) end
            end
        end)
        button:SetScript('PreClick', function(self, mouseButton)
            self.clickedSource = mouseButton == 'LeftButton' and self.craftClick and self.source or nil
        end)
        button:SetScript('PostClick', function(self, mouseButton)
            if mouseButton == 'LeftButton' then reconcileAt = GetTime() + .1 end
            local source = self.clickedSource
            self.clickedSource = nil
            if source then
                local script = source:GetScript('OnClick')
                if script then script(source, mouseButton) end
            end
        end)
        button:SetScript('OnLeave', function(self)
            ReleaseMouseHover(self)
        end)
        overlays[key] = button
    end
    local left, bottom = source:GetLeft(), source:GetBottom()
    if not left or not bottom then HideOverlay(button); return end
    local ratio = source:GetEffectiveScale() / host:GetEffectiveScale()
    if button.source ~= source then
        ReleaseMouseHover(button)
        if button.source and button.source.ffAutoFormClick == button then
            button.source.ffAutoFormClick = nil
        end
    end
    button.source = source
    button.craftClick = craftClick
    source.ffAutoFormClick = button
    button.generation = refreshGeneration
    local text = '/cancelform [form]\n'..macro
    if button:GetAttribute('macrotext') ~= text then button:SetAttribute('macrotext', text) end
    local x, y = left * ratio, bottom * ratio
    local width, height = source:GetWidth() * ratio, source:GetHeight() * ratio
    -- Do not hide/re-show or reanchor a stationary button during a held click.
    if button.x ~= x or button.y ~= y or button.width ~= width or button.height ~= height then
        button:ClearAllPoints()
        button:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', x, y)
        button:SetWidth(width)
        button:SetHeight(height)
        button.x, button.y, button.width, button.height = x, y, width, height
    end
    local strata, level = source:GetFrameStrata(), source:GetFrameLevel() + 5
    if button.strata ~= strata then button:SetFrameStrata(strata); button.strata = strata end
    if button.level ~= level then button:SetFrameLevel(level); button.level = level end
    if not button:IsShown() then button:Show() end
end
local function Refresh()
    if InCombatLockdown() then return end
    refreshGeneration = refreshGeneration + 1
    if GetShapeshiftForm() == 0 then
        for _, button in pairs(overlays) do HideOverlay(button) end
        return
    end
    if bookOpen and GossipFrame and GossipFrame:IsVisible() and not UnitExists('npc') then
        for i = 1, (NUMGOSSIPBUTTONS or 32) do
            local row = _G['GossipTitleButton'..i]
            if row and row:IsVisible() and row.type == 'Gossip' then
                local option = row:GetID()
                if option == 2 or option == 9 then
                    Place('Book'..option, row, '/run SelectGossipOption('..option..')')
                end
            end
        end
    end
    -- Preserve Blizzard's selected recipe, quantity, alternate verbs and scripts.
    -- As in the reference addon, explicit crafting clicks leave form first.
    for _, name in ipairs({'CraftCreateButton', 'TradeSkillCreateButton', 'TradeSkillCreateAllButton'}) do
        local row = _G[name]
        if row and row:IsVisible() and row:IsEnabled() then
            Place(name, row, '', true)
        end
    end
    if TaxiFrame and TaxiFrame:IsVisible() then
        for i = 1, NumTaxiNodes() do
            local row = _G['TaxiButton'..i]
            if row and row:IsVisible() and TaxiNodeGetType(row:GetID()) == 'REACHABLE' then
                Place('Taxi'..i, row, '/run TaxiNodeOnButtonEnter(TaxiButton'..i..'); TakeTaxiNode('..row:GetID()..')')
            end
        end
    end
    for _, button in pairs(overlays) do
        if button.generation ~= refreshGeneration then HideOverlay(button) end
    end
end
hooksecurefunc('GossipFrameUpdate', function()
    if pendingBook and GetTime() - pendingBook < 5 then
        bookOpen = not UnitExists('npc') and GetNumGossipOptions() >= 9
        pendingBook = nil
    end
    Refresh()
end)
local monitor = CreateFrame('Frame')
for _, event in ipairs({'GOSSIP_CLOSED', 'TAXIMAP_OPENED', 'TAXIMAP_CLOSED', 'UPDATE_SHAPESHIFT_FORM', 'PLAYER_REGEN_ENABLED'}) do
    monitor:RegisterEvent(event)
end
monitor:SetScript('OnEvent', function(self, event)
    if event == 'GOSSIP_CLOSED' then bookOpen, pendingBook = false, nil end
    if event == 'UPDATE_SHAPESHIFT_FORM' and reconcileAt then reconcileAt = GetTime() + .1 end
    Refresh()
end)
local elapsedTotal = 0
monitor:SetScript('OnUpdate', function(self, elapsed)
    elapsedTotal = elapsedTotal + elapsed
    if elapsedTotal < .1 then return end
    elapsedTotal = 0
    if reconcileAt and GetTime() >= reconcileAt and not InCombatLockdown() then
        reconcileAt = nil
        if ConsolePortBar and ConsolePortBar.ReconcileFormMenuState then
            ConsolePortBar:ReconcileFormMenuState()
        end
    end
    if pendingBook and GetTime() - pendingBook >= 5 then pendingBook = nil end
    Refresh()
end)
ab.formMenuMonitor = monitor
