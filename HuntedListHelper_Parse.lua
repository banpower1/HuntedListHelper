local FORMAT_UNKNOWN = 0;
local FORMAT_FIREFOX = 1;
local FORMAT_CHROME = 2;

local ExpectedHeaderFirefox = [[Hunted liste ALFA

    Hunted listeItems

                            
1
    Rang    Navn    Klasse    Item - MC    
MC Prio
    Item - BWL    
BWL Prio
                            
]]

local ExpectedHeaderChrome = [[Hunted liste ALFA
Hunted listeItems
Rang    Navn    Klasse    Item - MC    
MC Prio
Item - BWL    
BWL Prio
]]

local ExpectedLenFirefox = ExpectedHeaderFirefox:len();
local ExpectedLenChrome = ExpectedHeaderChrome:len();

local function DetectHeader(Hunted)
    if Hunted:sub(1, ExpectedLenFirefox) == ExpectedHeaderFirefox then
        return FORMAT_FIREFOX;
    end

    if Hunted:sub(1, ExpectedLenChrome) == ExpectedHeaderChrome then
        return FORMAT_CHROME;
    end

    return FORMAT_UNKNOWN;
end

local function SkipHeaderFirefox(Hunted)
    return Hunted:sub(ExpectedLenFirefox+1);
end

local function SkipHeaderChrome(Hunted)
    return Hunted:sub(ExpectedLenChrome+1);
end

local function CutFooter(Hunted)
    local ExpectedFooter = "Published by Google Sheets";
    local strStart, strEnd = Hunted:find(ExpectedFooter);
    return Hunted:sub(1, strStart-1);
end

local function ParseLine(line)
    local iBeg, iEnd, iBegOld, iEndOld = 0, 0, 0, 0;

    iBegOld, iEndOld = iBeg, iEnd;
    iBeg, iEnd = line:find("    ", iEnd+1);
    local role = line:sub(iEndOld+1, iBeg-1);
    
    iBegOld, iEndOld = iBeg, iEnd;
    iBeg, iEnd = line:find("    ", iEnd+1);
    local player = line:sub(iEndOld+1, iBeg-1);
    
    iBegOld, iEndOld = iBeg, iEnd;
    iBeg, iEnd = line:find("    ", iEnd+1);
    local class = line:sub(iEndOld+1, iBeg-1);
    
    iBegOld, iEndOld = iBeg, iEnd;
    iBeg, iEnd = line:find("    ", iEnd+1);
    local itemMC = line:sub(iEndOld+1, iBeg-1);
    
    iBegOld, iEndOld = iBeg, iEnd;
    iBeg, iEnd = line:find("    ", iEnd+1);
    local prioMC = line:sub(iEndOld+1, iBeg-1);
    
    iBegOld, iEndOld = iBeg, iEnd;
    iBeg, iEnd = line:find("    ", iEnd+1);
    local itemBWL = line:sub(iEndOld+1, iBeg-1);
    
    iBegOld, iEndOld = iBeg, iEnd;
    --iBeg, iEnd = line:find("    ", iEnd); -- Since this is the last entry we cant search further
    local prioBWL = line:sub(iEndOld+1);

    table.insert(HLH_HuntedList, {["role"]=role, ["player"]=player, ["class"]=class, ["itemMC"]=itemMC, ["prioMC"]=prioMC, ["itemBWL"]=itemBWL, ["prioBWL"]=prioBWL});
end

function HuntedListHelper_Parse(RawHuntedList)
    -- RawHuntedList = RawHuntedList.."\n";
    local format = DetectHeader(RawHuntedList);

    if format == FORMAT_UNKNOWN then
        return false;
    end
    if format == FORMAT_FIREFOX then
        local HuntedList = SkipHeaderFirefox(CutFooter(RawHuntedList));
        HLH_HuntedList = {};
        for line in HuntedList:gmatch("(.-)\n") do
            -- Firefox has the row numbers every other line
            -- Skip over those to find those with leading spaces, which contains the data
            if line:byte(1) == 32 then
                ParseLine(line:sub(5)); -- sub(5) so we skip leading spaces, and end up with same formatting as chrome
            end
        end
        return true;
    end
    if format == FORMAT_CHROME then
        local HuntedList = SkipHeaderChrome(CutFooter(RawHuntedList));
        HLH_HuntedList = {};
        for line in HuntedList:gmatch("(.-)\n") do
            ParseLine(line);
        end
        return true;
    end
end