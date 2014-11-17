PW_FORT = 'Power Word: Fortitude';

local working = false;

local function HexToRGBPerc(hex)
	local rhex, ghex, bhex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
	return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255
end

local RED_VALUE, GREEN_VALUE, BLUE_VALUE = HexToRGBPerc('aaaaaa');

function Buff_WriteChatMessage(what)
    DEFAULT_CHAT_FRAME:AddMessage('|cffff9900<|cffff6600Buff|cffff9900>|r ' .. what, RED_VALUE, GREEN_VALUE, BLUE_VALUE);
end

function Buff_OnLoad(self)
    Buff_WriteChatMessage('loaded');
    self:RegisterEvent('ADDON_LOADED');
end

function Buff_OnEvent(self, event, arg1, arg2, arg3, arg4)
    if (event == 'ADDON_LOADED' and arg1 == 'Preech_Buff') then
        SetOverrideBindingClick(PreechBuffFrame, false, 'MOUSEWHEELUP', 'Preech_Buff_KeyButton', 'MOUSEWHEELUP');
        SetOverrideBindingClick(PreechBuffFrame, false, 'MOUSEWHEELDOWN', 'Preech_Buff_KeyButton', 'MOUSEWHEELDOWN');
    end
end

function Preech_Buff_OnUpdate(self, elapsed)
end

function Buff_OnPreClick(self, button, down)
    local unit = nil;
    local typ = nil;
    local macro = nil;

    if not working and CanBeBuffed() then
        working = true;

        if NeedsBuff() then
            unit = 'player';
            typ = 'macro';
            macro = '/cast ' .. PW_FORT;
        else
            mh = GetInventoryItemID('player', INV_SLOT_MAIN_HAND);
            for p in pairs(POLES) do
                if mh == POLES[p] then
                    unit = 'player';
                    typ = 'macro';
                    macro = '/cast fishing';
                    break;
                end
            end
        end
    end

    Preech_Buff_KeyButton:SetAttribute('unit', unit);
    Preech_Buff_KeyButton:SetAttribute('type', typ);
    Preech_Buff_KeyButton:SetAttribute('macrotext', macro);
end

function Buff_OnPostClick(self, button, down)
    if (button) then
        if (button == 'MOUSEWHEELUP') then
            CameraZoomIn(1);
            working = false;
        elseif (button == 'MOUSEWHEELDOWN') then
            CameraZoomOut(1);
            working = false;
        end
    end
end

function CanBeBuffed()
    if IsFlying() or IsMounted() or UnitOnTaxi('player') or InCombatLockdown() then
        return false;
    end
    return true;
end

function NeedsBuff()
    local buffs, i = { }, 1;
    local buff = UnitBuff('player', i);
    while buff do
        if buff == PW_FORT then
            -- already buffed, bail
            return false;
        end
        i = i + 1;
        buff = UnitBuff('player', i);
    end

    return true;
end
