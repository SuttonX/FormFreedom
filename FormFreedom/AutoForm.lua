-- FormFreedom: independently named standalone adaptation; see README.md and LICENSE.md.
local _, ab = ...
if not ab.enabled then return end
local Bar = ab.bar
local db = ab.data
local band = bit.band
local forms = ab.cancellableForms
local restrictions = ab.formRestrictions
-- Spell masks use server form IDs; macro [form] uses the player's form-bar
-- index. Resolve names through this client's GetSpellInfo to support locales.
local stanceForms = {[2]=true, [28]=true, [31]=true}
function ab:FormActionRequiresExit(record, formID)
    if not record or not formID or record[6] then return false end
    local mask = 2 ^ (formID - 1)
    local noShift, allowed, forbidden, outside, mount = unpack(record)
    -- Leaving form cannot help an action that requires another form.
    if allowed ~= 0 and not outside then return false end
    if band(forbidden, mask) ~= 0 then return true end
    if band(allowed, mask) ~= 0 then return false end
    if not stanceForms[formID] and (noShift or mount) then return true end
    return false
end

local proxy = CreateFrame('Button', 'FormFreedomActionProxy', Bar, 'SecureActionButtonTemplate')
proxy:SetAttribute('type', 'action')
proxy:SetID(0) -- action is an absolute slot, never recalculated after cancelform.
proxy:RegisterForClicks('LeftButtonUp')
proxy:Hide()
Bar:SetFrameRef('FFAutoFormProxy', proxy)

local monitor = CreateFrame('Frame')
local pending = true
local oldKeys = {}
local nameRecords, rankRecords = {}, {}
local lookupPosition = 1
local function NameKey(name, rank) return name..'\031'..(rank or '') end
local function AddName(index, key, record)
    local old = index[key]
    if old == nil then index[key] = record or false
    elseif old ~= false and not db.table.compare(old, record) then index[key] = false end
end
local function BuildNames()
    -- Stock 3.3.5 GetItemSpell can return name/rank rather than a spell ID.
    -- Build a locale-aware lookup in small batches; conflicting records are
    -- rejected, including names shared with unrestricted spells.
    local ids = ab.formLookupIDs
    local stop = math.min(lookupPosition + 499, #ids)
    for i = lookupPosition, stop do
        local id = ids[i]
        local name, rank = GetSpellInfo(id)
        if name then
            local record = restrictions[id]
            AddName(nameRecords, name, record)
            AddName(rankRecords, NameKey(name, rank), record)
        end
    end
    lookupPosition = stop + 1
    if lookupPosition > #ids then
        ab.formLookupIDs = nil
        pending = true
        return true
    end
end
local function Refresh()
    if InCombatLockdown() then pending = true; return end
    for _, key in ipairs(oldKeys) do Bar:SetAttribute(key, nil) end
    wipe(oldKeys)
    Bar:SetAttribute('FFAutoFormCursorBusy', GetCursorInfo() and true or false)
    local function Put(key, value)
        Bar:SetAttribute(key, value)
        oldKeys[#oldKeys+1] = key
    end
    local slots = {}
    for index = 1, GetNumShapeshiftForms() do
        local _, formName = GetShapeshiftFormInfo(index)
        for formID, spellID in pairs(forms) do
            if formName == GetSpellInfo(spellID) then
                slots[index] = formID
                break
            end
        end
    end
    local missingItems = false
    for slot = 1, 180 do
        local kind, id, subtype = GetActionInfo(slot)
        local spellID, itemRecord
        if kind == 'spell' then
            spellID = id
        elseif kind == 'item' and id ~= 9017 then
            if not GetItemInfo(id) then missingItems = true end
            local name, rankOrID, itemSpellID = GetItemSpell(id)
            if type(itemSpellID) == 'number' then spellID = itemSpellID
            elseif type(rankOrID) == 'number' then spellID = rankOrID
            elseif name and not ab.formLookupIDs then
                itemRecord = rankRecords[NameKey(name, rankOrID)] or nameRecords[name]
            end
            -- Hearthstone's item/spell identity is unambiguous in stock 3.3.5.
            if not spellID and id == 6948 then spellID = 8690 end
        elseif kind == 'companion' and subtype == 'MOUNT' then
            local _, _, mountSpellID = GetCompanionInfo('MOUNT', id)
            spellID = mountSpellID
        end
        local record = (spellID and restrictions[spellID]) or itemRecord
        if kind == 'companion' and subtype == 'MOUNT' and not record then
            -- The mount journal identifies new/custom mounts even if their
            -- spell is not in our stock-data manifest.
            record = {false, 0, 0, false, true}
        end
        if record then
            local useful
            for index, formID in pairs(slots) do
                if ab:FormActionRequiresExit(record, formID) then
                    Put('FFAutoForm-'..slot..'-'..index, true)
                    useful = true
                end
            end
            if useful then
                Put('FFAutoFormKind-'..slot, kind)
                Put('FFAutoFormID-'..slot, id)
                Put('FFAutoFormSubtype-'..slot, subtype)
            end
        end
    end
    pending = missingItems
end
monitor:SetScript('OnEvent', function(self, event)
    pending = true
    if event == 'PLAYER_REGEN_ENABLED' or event == 'PLAYER_ENTERING_WORLD' or event == 'CURSOR_UPDATE' then Refresh() end
end)
-- Coalesce action/item/form changes and only write secure attributes out of combat.
monitor:SetScript('OnUpdate', function(self, elapsed)
    if ab.formLookupIDs then BuildNames() end
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= 0.25 then
        self.elapsed = 0
        if pending and not InCombatLockdown() then Refresh() end
    end
end)
for _, event in ipairs({'PLAYER_ENTERING_WORLD', 'PLAYER_REGEN_ENABLED',
    'ACTIONBAR_SLOT_CHANGED', 'SPELLS_CHANGED', 'UPDATE_SHAPESHIFT_FORMS',
    'COMPANION_UPDATE', 'BAG_UPDATE', 'CURSOR_UPDATE'}) do
    monitor:RegisterEvent(event)
end
