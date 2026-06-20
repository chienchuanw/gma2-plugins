--*******************************************************************************************
-- This script prepares any showfile for the test scripts
-- !Attention this script gonna destroy your showfile. Never load this while a show!
-- This is a concept only for the test scripts. A general function will follow later.
-- It will start directly by load to prevent errors.
--*******************************************************************************************
-- This is set for testing and running combined with test_main_matrix.
-- For running this file standalone, remove all [[]] comments.
--*******************************************************************************************

-- Errors at the moment:
-- Labelling of objects doesn't work in the loop
-- PosXYZ doesn't work
-- Patching of Mov_Path isn't set later

local E=gma.echo;
local C=gma.cmd;
local F=gma.feedback;
local O=gma.show.getobj;
local U=gma.user;

local dev = false;
local server_nc = false;
local host_version = gma.show.getvar("VERSION");
yield = true;

--*******************************************************************************************
-- Properties Loader
-- is only executed if main_matrix is not in the same namespace
-- Needed for standalone use!
--*******************************************************************************************

--[[function loadProperties()
    local properties = {};
    if compare_versions(host_version,"3.1.3.0") then
         properties = gma.import("property.xml","plugins/systemtests/other");--loads the plugins
         if dev then
            gma.echo("Loaded Properties...");
            gma.echo('Properties: ');
            gma.echo("Version: " .. properties.version);
            gma.echo("GS: " .. tostring(properties.golden_samples));   --set as true by property.xml 
            gma.echo("Server: " .. tostring(properties.server));
            for i = 1, #properties.ignore do
                gma.echo("Ignore " .. i .. ": " .. properties.ignore[i]);---ignore table of property.xml
            end
            for i = 1, #properties.fixtures do
                gma.echo("Fixture " .. i .. ": " .. properties.fixtures[i]);--fixtures of prperties.xml
            end
            if properties.fixture_channel_count then
                for i = 1, #properties.fixture_channel_count do 
                    gma.echo("Fixture " .. i .. " has : " .. properties.fixture_channel_count[i] .. " channels.");
                end
            else
                gma.echo("Fixture-channel-count not found.");
                for i = 1, #properties.fixtures do
                    properties.fixture_channel_count[i] = -1;
                end
            end
            for i = 1, #properties.fixture_count do
                gma.echo("Count " .. i .. ": " .. properties.fixture_count[i]);
            end
            if compare_versions(host_version,"3.1.0.0") then
                gma.sleep(2);
            else
                coroutine.yield(2);----------causes RUNTIME ERROR-attempt to yield from outside a coroutine!!
            end
         end
    else
        local path=gma.show.getvar("PATH");
        local file = assert(io.open(path .. "/plugins/systemtests/other/properties.xml","r"));
        local result = file:read("*all");
        file:close();
        -- Parsing result
        local beginnings = {};
        local endings = {};
        if result then
            -- find the xml blocks
            local i = 0;
            while true do
              i = string.find(result, "<", i+1)    -- block beginnings
              if i == nil then 
                --gma.echo("Found " .. #beginnings .. " '<'")
                break 
              end
              table.insert(beginnings, i)
            end
            i = 0;
            while true do
              i = string.find(result, ">", i+1)    -- block endings
              if i == nil then
                 --gma.echo("Found " .. #endings .. " '>'")
                 break 
              end
              table.insert(endings, i)
            end
            -- if blocks found
            if #beginnings > 0 and #endings > 0 then
                local blockcount = #beginnings;
                --gma.echo(blockcount);
                -- check if file is valid
                if string.find(result, "Prop", beginnings[0]) then
                    local loaded = 0;
                    for i=2, blockcount do
                        currentblock = string.sub(result,beginnings[i]+1,endings[i]-1);
                        if not string.find(currentblock, "/Prop") then
                            local separator = string.find(currentblock,"=");
                            if separator then
                                local key = string.sub(currentblock,0,separator-1);
                                local value = string.sub(currentblock,separator+1,#currentblock);
                                -- Remove leaved spaces
                                if string.find(key," ") then
                                    --gma.echo("removed space on key");
                                    key = string.sub(key,0,#key-1);
                                end
                                if string.find(value," ") then
                                    --gma.echo("removed space on value");
                                    value = string.sub(value,2,#value);
                                end
                                if dev then
                                    gma.echo("Detected Key " .. key .. " with the value " .. value);
                                end
                                -- Insert property into the table
                                table.insert(properties,key);
                                table.insert(properties,value);
                                loaded = loaded+1;
                            else
                                gma.echo("No value assiged to property: ".. currentblock);
                            end
                        else
                            -- end of list
                            gma.echo("Loaded " .. loaded .. " porperties sucessfully.");
                            if dev then
                                E('sleeping for 2 sec.');
                                gma.sleep(2);
                            end
                            break;
                        end
                    end
                else
                    gma.echo("No 'Prop'-Block found. File seems to be invalid!");
                end
            else
                gma.echo("No Blocks found. File seems to be invalid!");
            end        
        end
    end
    return properties;
end

--*******************************************************************************************
-- Properties interpreter
-- is only executed if main_matrix is not in the same namespace
--*******************************************************************************************

function get_prop_fixturecount(properties)
    if not properties then
        properties = loadProperties();
    end
    
    local fc;
    if compare_versions(host_version,"3.1.3.0") then
        -- Using gma.import();
        fc = properties.fixture_count;
    else
        if properties[7] == "fixtures_count" then
            if string.find(properties[8],"{") then
                fc = { };
                local pos = { };
                table.insert(pos, 2); -- Cut '{'
                i = 1;
                while true do
                    i = string.find(properties[8], ",", i+1);    -- number blocks
                    if i == nil then
                        if dev then
                            gma.echo("Found " .. #pos .. " attributes");
                        end
                        break;
                    end
                    table.insert(pos, i);
                end
                table.insert(pos, #properties[8]-1); -- Cut '}'
                if #pos > 2 then
                    for i = 1, #pos-1 do
                        local currentattr = string.sub(properties[8],pos[i],pos[i+1]);
                        while true do
                            local tmp = string.find(currentattr,',');
                            if tmp then
                                -- get if it is on te beginning or at the end
                                if tmp ==1 then
                                    currentattr = string.sub(currentattr,2,#currentattr);
                                else
                                    currentattr = string.sub(currentattr,1,#currentattr-1);
                                end
                                -- gma.echo("removed comma");
                            else
                                break;
                            end
                        end
                        table.insert(fc, tonumber(currentattr));
                    end
                end
            else
                fc = properties[8];
            end
        end
    end
    return fc;
end

-----------------------------------------------------------------------------------------
-- Verarbeitung einer Versionsnummer
-- is only executed if main_matrix is not in the same namespace
-----------------------------------------------------------------------------------------

function get_version_numbers(vers)
    local s = {};
    if vers then
        local pos = {};
        table.insert(pos, 1);
        local i = 0;
        while true do
            i = string.find(vers, '%.', i+1);    -- number blocks
            if i == nil then
                --gma.echo("Found " .. #pos .. " numbers");
                break 
            end
            table.insert(pos, i);
        end
        table.insert(pos, #vers);
        if #pos > 2 then
            for i = 1, #pos-1 do
                local currentno = string.sub(vers,pos[i],pos[i+1]);
                while true do
                    local tmp = string.find(currentno,'%.');
                    if tmp then
                        -- get if it is on te beginning or at the end
                        if tmp ==1 then
                            currentno = string.sub(currentno,2,#currentno);
                        else
                            currentno = string.sub(currentno,1,#currentno-1);
                        end
                        --gma.echo("removed comma");
                    else
                        break;
                    end
                end
                table.insert(s, tonumber(currentno));
            end
        end
        if dev then
            F(s[1] .. " " .. s[2] .. " " .. s[3] .. " " .. s[4]);
        end
    else
       if dev then
         F("Can't find a version number!");
       end
    end
    return s;
end

function compare_versions(number1,number2)
    if dev then
        F('Comparing Versions...');
        F('Host: ' .. number1 .. ' Version Numbers:');
    end
    
    local n1 = get_version_numbers(number1);
    
    if number2 then
        if dev then
            F('Script/Step: ' .. number2 .. ' Version Numbers:');
        end
        local n2 = get_version_numbers_spec(number2);
        -- Compare
        if n2 then
            for i=1,#n1 do
                if n1[i] < n2[i] then
                    return false;
                end
            end
        else
            F('Error: No Version Table found. Compare faild!');
            return false;
        end
    else
        if dev then
            F("No version given!");
        end
        return true;
    end
    return true;
end
]]

--*******************************************************************************************
-- setup fixture layer
-- layerValue is the number of the layer, e.g. 3
-- and layerName, e.g. led_-_rgbs
--*******************************************************************************************

function storeLayer(layerValue,layerName,offset)
    gma.cmd('cd /; cd "EditSetup"; cd "Layers"');
    if compare_versions(host_version,"3.1.0.0") then
        if dev then
            F('Layer offset:' .. tostring(offset.layer));
        end
        if not offset.layer then
            local handle = gma.show.getobj.handle("1");
            if handle then
                local name = gma.show.getobj.name(handle);
                if dev then
                    F("Current name of first layer" .. name);
                end
                if name == "Auto-Created 1" then
                    offset.layer = true;
                    C('s ' .. layerValue+1 .. " " .. layerName);
                else
                    local res=true;
                    if not server_nc and not host_version == "3.1.2.5" then -- In version 3.1.2.5 dialogs are broken!
                        res = gma.gui.confirm("Init Processing","There is no Auto-Created Fixture until now. Should the search be continued?");
                        if res then
                            F('Looping until Autocreated is present!');
                            storeLayer(layerValue,layerName,offset);
                        end
                    end
                end
            else
                F("Can't get Layerindex-Handle. Creating Dummy.");
                C('s 1 ' .. layerName .. '; cd /');
                
                local res=true;
                if not server_nc and not host_version == "3.1.2.5" then -- In version 3.1.2.5 dialogs are broken!
                    res = gma.gui.confirm("Init Processing","There is no Auto-Created Fixture until now. Should the search be continued?");
                end
                if res then
                    F('Looping until Autocreated is present!');
                    storeLayer(layerValue,layerName,offset);
                end
                
            end
        else
            C('s ' .. layerValue+1 .. " " .. layerName);
        end
    else
        C('s ' .. layerValue .. " " .. layerName);
    end
    return offset;
end

function storeFixtures(layerValue, layerName, quantity, fixType, channels, fixno, offset, setpos, posy, angle)
    offset = storeLayer(layerValue,layerName,offset);
        
    E('Sleeping for 1000ms');
    F('Sleeping for 1000ms');
    if compare_versions(host_version,"3.1.0.0") then
        gma.sleep(1);
    else
        coroutine.yield(1);
    end
    E('Continue');

    C('cd ' .. layerName);                                   --enters Menu of fixturetypes
    --
    local addr = 0;
    local layer=U.getcmddest();
    if(O.class(layer)=="CMD_FIXTURE_LAYER") then             --checks if the class object is "CMD_FIXTURE_LAYER"
        C('store 1 thru '.. quantity);                       -- create quantity objects
        if offset then
            if fixno then                                    -- difference between channels and fixtures
                C('assign thru /FixId=' .. offset.fixID);
            else
                C('assign thru /ChaId=' .. offset.chID);
            end
            
            if compare_versions(host_version,"3.1.0.0") then
                C('assign ft ' .. fixType+1 .. ' at thru '); -- considering AutoCreated Fixtures at ft 1
            else
                C('assign ft ' .. fixType .. ' at thru ');
            end    
        end
        
        E('Sleeping for 1000ms');
        F('Sleeping for 1000ms');
        if compare_versions(host_version,"3.1.0.0") then
            gma.sleep(1);
        else
            coroutine.yield(1);
        end
        E('Continue');

        --patching
        if offset.patch and channels > 0 then
            for ding=0,quantity-1 do -- ding is the index of the current fixture type patch iteration
                if(offset.patch+((ding+1)*channels) > 512) then
                    offset.patch = offset.patch-(offset.patch+(ding*channels))+1;
                    offset.universe = offset.universe + 1;
                end
                addr = offset.patch+(ding*channels);
                
                C('cd '..(ding+1));
                C('assign 1 /Patch= '.. offset.universe .. '.' .. addr);
                C('cd ..');
                if(setpos)then -- Positioning objects
                    if(fixno) then
                        C('assign Fixture '.. offset.fixID+ding .. ' /posx=' .. -21+ding*2 .. ' /posy=' .. posy .. ' /posz= 5 /rotx=' .. angle);
                    else
                        C('assign Channel '.. offset.chID+ding .. ' /posx=' .. -21+ding*2 .. ' /posy=' .. posy .. ' /posz= 5 /rotx=' .. angle);
                    end
                end
            end
        else
            if channels < 1 then
                F('Patching error: Failed to get channel count of fixture: ' .. layerName .. '.');
            else
                F('Patching done via default.');
            end
        end
    else
        F("Failed to enter fixture layer.");
        result=false;
    end
    C('cd..');
    
    if offset then
        if offset.patch and channels > 0 then
            offset.patch = addr + channels;
        end
        if fixno then
            offset.fixID = offset.fixID+quantity;
        else
            offset.chID = offset.chID+quantity;
        end
    end
    return offset
end

function labelObjects(label, fixno, offset, quantity)
    local labelindex = 1;
    if fixno then
        for index=1,quantity do
            C('label Fixture ' .. index+offset.fixID-1 .. ' "'.. label .. labelindex ..'"');
            labelindex = labelindex+1;
        end
    else
        for index=1,quantity do
            C('label Channel ' .. index+offset.chID-1 .. ' "'.. label .. labelindex ..'"');
            labelindex = labelindex+1;
        end
    end
    
    if offset then
        if fixno then
             offset.fixID = offset.fixID+quantity;
             return offset.fixID
        else
             offset.chID = offset.chID+quantity;
             return offset.chID
        end
    end
end

local function INIT_FIXTURES()

    F('Initalizing Showfile... Version 1.1');
    E('Loading Properties form file...');
    local proptable = loadProperties();
    if proptable then
        E('done');
        
        local result=true;
        set_prop_server_spec(proptable);
        if dev then
            gma.echo("Server-Flag: " .. tostring(server_nc));
        end
        if not server_nc and not host_version == "3.1.2.5" then -- In version 3.1.2.5 dialogs are broken!
            result = gma.gui.confirm("Danger!","This operation destroys your showfile. Do you want to proceed?");
            if(result) then
                result = gma.gui.confirm("Danger!","Are you sure?");
            end
        else
            E('Server-Property enabled. Starting without dialogs...');
        end
        
        local fixturecount = { };
        local fixturename = { };
        local fixture_channel_count = { };
        
        if(result) then
            C('ClearAll; cd /; cd "EditSetup"');
            local setup=U.getcmddest();
            if(O.class(setup)=="CMD_SETUP") then                             -- Verifikation des menu-levels
                C('delete ft thru ');
                -- load fixturetypes
                local fixturetype = get_prop_fixturetypes(proptable);
                if (type(fixturetype) == "table") then
                    for i = 1, #fixturetype do
                        if compare_versions(host_version,"3.1.0.0") then
                            C('import ' .. fixturetype[i] .. ' at fixturetype ' .. i+1); -- considering AutoCreated Fixtures at ft 1
                        else
                            C('import ' .. fixturetype[i] .. ' at fixturetype ' .. i);
                        end
                    end
                else
                    C('import ' .. fixturetype .. ' at fixturetype 1');
                end
                
                -- adding layers
                C('cd "Layers"');                                             -- Enter in Layers
                local layers=U.getcmddest();
                if(O.class(layers)=="CMD_FIXTURE_LAYER_COLLECT") then
                
                    C('delete thru /nc');                                     -- delete all
                    
                    local offset = {};
                    offset.fixID = 1;
                    offset.chID  = 1;
                    offset.patch = 1;
                    offset.universe = 1;
                    offset.layer = false;
                    
                    E('Sleeping for 500ms');
                    if compare_versions(host_version,"3.1.0.0") then
                        gma.sleep(0.5);
                    else
                        coroutine.yield(0.5);
                    end
                    E('Continue');
                    
                    -- getting fixture names
                    fixturename = get_prop_fixturenames(proptable);
                    
                    -- getting fixture counts
                    fixturecount = get_prop_fixturecount(proptable);
                    
                    -- getting fixture channel counts
                    fixture_channel_count = get_prop_fixturechannelcount(proptable);
                    
                    if (type(fixturecount) == "table") then
                        if dev then
                            gma.echo("Loop will be called " .. #fixturetype .. " times");
                        end
                        for i = 1, #fixturetype do
                            gma.echo("Fitxturetype '" .. fixturename[i] .. "' will be patched " .. fixturecount[i] .. " times");
                            if string.find(fixturename[i],"dim") then
                                offset = storeFixtures( i, fixturename[i] .. "s", fixturecount[i], i, fixture_channel_count[i], false, offset);
                            else
                                offset = storeFixtures( i, fixturename[i] .. "s", fixturecount[i], i, fixture_channel_count[i], true, offset);
                            end
                        end
                    else
                        storeFixtures(2, "Devices", fixturecount, 1, -1, true,offset);
                    end
                else
                    E("Failed to enter fixture layer collect");
                    result=false;
                end
                C('cd /'); -- leave setup
                ------------------------------------------------------------------------------------------------------------------------
                -- Label Routine. Muss noch in die storeFixtures Routine integriert werden....
                ------------------------------------------------------------------------------------------------------------------------
                local offset = {};
                offset.fixID = 1;
                offset.chID  = 1;
                
                --[[if (type(fixturecount) == "table") then
                    if dev then
                        gma.feedback("Loop will be called " .. #fixturecount .. " times");
                    end
                    for i = 1, #fixturecount do
                        if dev then
                            gma.feedback(i);
                            gma.feedback(fixturecount[i]);
                        end
                        if string.find(fixturename[i],"dim") then
                            offset.chID = labelObjects(fixturename[i], false, offset, fixturecount[i]);
                        else
                            offset.fixID = labelObjects(fixturename[i], true, offset, fixturecount[i]);
                        end
                    end
                else
                    offset.fixID = labelObjects(fixturename, true, offset, fixturecount);
                end]]
                -------------------------------------------------------------------------------------------------------------------------
            else
                E("Failed to enter full access setup");
                result=false;
            end
            C('cd /');
        else
            E('Fixture Init: Abort by user.');
        end
    else
        E('Failed to load properties. Canceling routine');
    end
    yield = false;
end

return INIT_FIXTURES;