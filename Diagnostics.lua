-- Opt-in read-only diagnostics. Never retries, cancels form or changes bindings.
local addonName, ns = ...
if not ns.enabled then return end
local capture, showAt, window
local function Add(line)
    if capture and #capture.lines < 60 then capture.lines[#capture.lines + 1] = line end
end
local function ItemID(value)
    if type(value) == 'number' then return value end
    if type(value) == 'string' then return tonumber(value:match('item:(%d+)')) or tonumber(value) end
end
local function RecordItem(value, path)
    if not capture then return end
    local id = ItemID(value)
    if not id and type(value) == 'string' then
        local _, link = GetItemInfo(value)
        id = ItemID(link)
    end
    Add(path..': item ID='..tostring(id or 'unknown')..'; value='..tostring(value or 'unknown'))
end
local function FormName()
    local index = GetShapeshiftForm()
    if index == 0 then return 'Humanoid' end
    local _, name = GetShapeshiftFormInfo(index)
    return tostring(name or 'unknown')..' (index '..index..')'
end
local function ShowReport()
    if not capture then return end
    local version = GetAddOnMetadata and GetAddOnMetadata(addonName,'Version') or '1.0.1'
    local text = 'FormFreedom report\nAddon: '..tostring(version)..'; target: WotLK 3.3.5a\nClient: '..tostring(GetBuildInfo())
        ..'\nRealm: '..tostring(GetRealmName())..'\nStarted in: '..capture.form
        ..'\nEnded in: '..FormName()..'\nElvUI loaded: '..tostring(IsAddOnLoaded('ElvUI'))
        ..'\nConsolePortBar loaded: '..tostring(IsAddOnLoaded('ConsolePortBar'))..'\n\n'
        ..(#capture.lines > 0 and table.concat(capture.lines, '\n') or 'No supported action hooks captured. Describe the exact action/menu manually.')
        ..'\n\nPlease add server name, expected behavior and steps to reproduce. IDs may be unavailable for custom server actions.'
    capture, showAt = nil, nil
    if not window then
        local frame = CreateFrame('Frame', 'FormFreedomReportFrame', UIParent, 'UIPanelDialogTemplate')
        frame:SetPoint('CENTER')
        frame:SetFrameStrata('DIALOG')
        frame:SetWidth(UIParent:GetWidth() * .55)
        frame:SetHeight(UIParent:GetHeight() * .55)
        local width, height = frame:GetWidth(), frame:GetHeight()
        local title = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
        title:SetPoint('TOPLEFT', width * .04, -height * .08)
        title:SetText('FormFreedom — capture report')
        local help = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        help:SetPoint('TOPLEFT', width * .04, -height * .16)
        help:SetText('Click the text, press Ctrl+A then Ctrl+C. Paste it into your GitHub issue.')
        local scroll = CreateFrame('ScrollFrame', nil, frame, 'UIPanelScrollFrameTemplate')
        scroll:SetPoint('TOPLEFT', width * .04, -height * .24)
        scroll:SetPoint('BOTTOMRIGHT', -width * .08, height * .06)
        local edit = CreateFrame('EditBox', nil, scroll)
        edit:SetWidth(width * .86)
        edit:SetMultiLine(true)
        edit:SetFontObject(ChatFontNormal)
        edit:SetAutoFocus(false)
        edit:SetScript('OnEscapePressed', function() frame:Hide() end)
        scroll:SetScrollChild(edit)
        frame.edit = edit
        window = frame
        tinsert(UISpecialFrames, 'FormFreedomReportFrame')
    end
    window.edit:SetText(text)
    window:Show()
    window.edit:SetFocus()
    window.edit:HighlightText()
end
local function Hook(name, callback)
    if type(_G[name]) == 'function' then hooksecurefunc(name, callback) end
end
Hook('UseContainerItem', function(bag, slot) RecordItem(GetContainerItemLink(bag, slot), 'Bag '..bag..' slot '..slot) end)
Hook('UseItemByName', function(item) RecordItem(item, 'UseItemByName') end)
Hook('UseAction', function(slot)
    if not capture then return end
    local kind, id, subtype, spellID = GetActionInfo(slot)
    Add('Action slot '..slot..': type='..tostring(kind)..'; ID='..tostring(id)..'; subtype='..tostring(subtype)..'; spell ID='..tostring(spellID or (kind == 'spell' and id) or 'unknown'))
    if kind == 'item' then RecordItem(id, 'Bar item') end
    if kind == 'companion' and subtype == 'MOUNT' then
        local _, name, mountSpell = GetCompanionInfo('MOUNT', id)
        Add('Mount '..tostring(name)..': spell ID='..tostring(mountSpell))
    end
end)
Hook('CastSpellByID', function(id) if capture then Add('CastSpellByID: spell ID='..tostring(id)) end end)
Hook('CastSpellByName', function(name)
    if not capture then return end
    Add('CastSpellByName: '..tostring(name)..'; spell ID may be unavailable from this API')
    local link = GetSpellLink and GetSpellLink(name)
    if link then Add('Spell link: '..link) end
end)
Hook('CastSpell', function(index, book)
    if not capture then return end
    local link = GetSpellLink and GetSpellLink(index, book)
    Add('Spellbook index '..tostring(index)..': '..tostring(link or 'spell ID unavailable'))
end)
Hook('SelectGossipOption', function(option)
    if not capture then return end
    local choices = {GetGossipOptions()}
    Add('Gossip option '..tostring(option)..': '..tostring(choices[(option - 1) * 2 + 1] or 'text unavailable'))
end)
Hook('TakeTaxiNode', function(node) if capture then Add('Taxi node '..node..': '..tostring(TaxiNodeName(node))) end end)
Hook('DoTradeSkill', function(index, count)
    if not capture then return end
    local link = GetTradeSkillRecipeLink and GetTradeSkillRecipeLink(index)
    Add('Craft recipe index '..tostring(index)..'; quantity='..tostring(count)..'; recipe link='..tostring(link or 'ID unavailable'))
end)
Hook('DoCraft', function(index)
    if not capture then return end
    Add('Craft index '..tostring(index)..'; item link='..tostring(GetCraftItemLink and GetCraftItemLink(index) or 'ID unavailable'))
end)
local monitor = CreateFrame('Frame')
monitor:RegisterEvent('UI_ERROR_MESSAGE')
monitor:SetScript('OnEvent', function(self, event, message)
    if capture then
        Add('Error text: '..tostring(message))
        showAt = GetTime() + .3
    end
end)
monitor:SetScript('OnUpdate', function()
    if capture and ((showAt and GetTime() >= showAt) or GetTime() >= capture.expires) then ShowReport() end
end)
SLASH_FORMFREEDOMREPORT1 = '/ffreport'
SlashCmdList.FORMFREEDOMREPORT = function()
    if capture then ShowReport(); return end
    capture = {form = FormName(), lines = {}, expires = GetTime() + 30}
    showAt = nil
    print('|cff7fe6baFormFreedom:|r recording for 30 seconds. Click the failing action while shifted. Run /ffreport again to show the report early.')
end
ns.diagnosticMonitor = monitor
