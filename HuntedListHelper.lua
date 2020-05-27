HuntedListHelper = LibStub("AceAddon-3.0"):NewAddon("HuntedListHelper", "AceConsole-3.0", "AceEvent-3.0");
local AceConfig = LibStub("AceConfig-3.0");
local AceConfigDialog = LibStub("AceConfigDialog-3.0");

function HuntedListHelper:OnInitialize()
    -- Code that runs when the addon is first loaded
    HuntedListHelper:RegisterChatCommand("hlh", "SlashProcessor");
    HuntedListHelper:RegisterChatCommand("hlhp", "PlayerLookup");
    tinsert(UISpecialFrames, HuntedListHelper_ImportFrame:GetName());
    
    HuntedListHelper_ImportFrame_ButtonUpdate:SetScript("OnClick", HuntedListHelper_UpdateHuntedList)

    HuntedListHelper_ImportFrame_EditBox:SetScript("OnKeyDown", function(self, key)
        if GetBindingFromClick(key)=="TOGGLEGAMEMENU" then
            HuntedListHelper_ImportFrame:Hide();
        end
    end);

    HuntedListHelper:RegisterEvent("CHAT_MSG_RAID_WARNING");

    if HLH_HuntedList == nil then
        HLH_HuntedList = {};
    end
    if HuntedListHelper_OutputChannel == nil then
        HuntedListHelper_OutputChannel = "debug";
    end

    HuntedListHelper_OptionsTable = {
        type = "group",
        args = {
            channel = {
                name = "Output channel",
                desc = "The channel that Hunted Loot Helper outputs to",
                type = "select",
                values = { ["RAID"]="Raid", ["GUILD"]="Guild", ["PARTY"]="Party", ["debug"]="Debug"},
                style = "dropdown",
                set = function(info, val) HuntedListHelper_OutputChannel = val end,
                get = function(info) return HuntedListHelper_OutputChannel end
            }
        }
    };

    AceConfigDialog:AddToBlizOptions("HuntedListHelper", "Hunted List Helper");
    AceConfig:RegisterOptionsTable("HuntedListHelper", HuntedListHelper_OptionsTable);
end

function HuntedListHelper:OnEnable()
    -- Called when the addon is enabled
end

function HuntedListHelper:OnDisable()
    -- Called when the addon is disabled
end

-- --------------------
-- | Helper functions |
-- --------------------
local function GetLinkedItemName(item)
    -- GetItemInfo(item) only works if you have seen the item this session (bank, inv, equipped) when looking up items based on pure ascii strings
    local itemNameBegin, itemNameEnd, dump = 0, 0, 0;
    dump, itemNameBegin = string.find(item, "[", 1, true);
    itemNameEnd, dump = select(1, string.find(item, "]", 1, true));
    return string.sub(item, itemNameBegin+1, itemNameEnd-1);
end

local function Msg(text)
    if HuntedListHelper_OutputChannel == "debug" then
        print(text);
    else
        if HuntedListHelper_OutputChannel == "RAID" then
            if IsInRaid() then
                SendChatMessage(text, "RAID");
            else
                print(text);
            end
        end
        if HuntedListHelper_OutputChannel == "GUILD" then
            SendChatMessage(text, "GUILD");
        end
        if HuntedListHelper_OutputChannel == "PARTY" then
            if IsInGroup() then
                SendChatMessage(text, "PARTY");
            else
                print(text);
            end
        end
    end
end

local function CheckItem(item)
    local itemname = "";
    if string.byte(item, 1) == 124 then
        itemname = GetLinkedItemName(item);
    else
        itemname = item;
    end
    Msg("Checking list for "..itemname);
    local HuntFound = false;
    for i=1,#HLH_HuntedList do
        if itemname == HLH_HuntedList[i]["itemMC"] then
            Msg("Prio "..HLH_HuntedList[i]["prioMC"].." - "..HLH_HuntedList[i]["player"].." for "..HLH_HuntedList[i]["itemMC"]);
            HuntFound = true;
        end
        if itemname == HLH_HuntedList[i]["itemBWL"] then
            Msg("Prio "..HLH_HuntedList[i]["prioBWL"].." - "..HLH_HuntedList[i]["player"].." for "..HLH_HuntedList[i]["itemBWL"]);
            HuntFound = true;
        end
    end
    if not HuntFound then
        Msg(itemname.." is not hunted!");
    end
    return HuntFound;
end
-- ------------------
-- | Main functions |
-- ------------------

function HuntedListHelper_UpdateHuntedList(self)
    local RawHuntedList = HuntedListHelper_ImportFrame_EditBox:GetText();
    HuntedListHelper_ImportFrame_EditBox:SetText("");
    HideUIPanel(HuntedListHelper_ImportFrame);
    if HuntedListHelper_Parse(RawHuntedList) then
        print("Huntedlist Updated");
    else
        print("Error parsing input");
    end
end

function HuntedListHelper:SlashProcessor(input)
    if input == "" then
        ShowUIPanel(HuntedListHelper_ImportFrame);
    else
        if #HLH_HuntedList == 0 then
            print("!WARNING! Huntedlist empty !WARNING!");
        else
            CheckItem(input);
        end
    end
end

function HuntedListHelper:PlayerLookup(input)
    if input == "" then
        print("No player listed");
    else
        if #HLH_HuntedList == 0 then
            print("!WARNING! Huntedlist empty !WARNING!");
        else
            Msg("Looking up "..input.." in the Hunted List...");
            local PlayerFound = false;
            for i=1,#HLH_HuntedList do
                if input:lower() == HLH_HuntedList[i]["player"]:lower() then
                    PlayerFound = true;
                    Msg(HLH_HuntedList[i]["player"].." is hunting "..HLH_HuntedList[i]["itemMC"].." in MC with prio "..HLH_HuntedList[i]["prioMC"].." and "..HLH_HuntedList[i]["itemBWL"].." in BWL with prio "..HLH_HuntedList[i]["prioBWL"]);
                end
            end
            if not PlayerFound then
                Msg("|cffff0000Player '"..input.."' not found|r");
            end
        end
    end
end

function HuntedListHelper:CHAT_MSG_RAID_WARNING(eventName, msg, sender, lang, chatlineid, senderguid)
    local ItemPurple = "|cffa335ee|Hitem";
    if ItemPurple == msg:sub(1, ItemPurple:len()) then
        CheckItem(msg);
    end
end