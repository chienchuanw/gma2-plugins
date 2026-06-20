--***********************************************************************
-- Testframe for LUA testing
--**********************************************************************

local E=gma.echo;
local F=gma.feedback;
local C=doCMD;
local G=gma.show.getobj;

--*******************************************************************************************
-- Testmatrix version & flags
--*******************************************************************************************

local lua_test_version = "1.3";

local serverIPs = {"10.0.255.65","10.0.255.83"};
local server = false;

local destructive_flag = false;

cancel = false;

--*******************************************************************************************
--Allow creation of missing Golden Samples?
--Ask every time before creating a missing Golden Sample?
--*******************************************************************************************

local create_missing_golden_samples = true;

local ask_every_single_time = false;

debug = false;

--*******************************************************************************************
--Create Log file for every single Script?
--*******************************************************************************************

--local writesingleErrLog = false;

--*******************************************************************************************
--Show more information?
--*******************************************************************************************

local dev = false; --true= show issues, considerably less single testscripts are loaded

--*******************************************************************************************
--Get Version
--*******************************************************************************************

local host_version = gma.show.getvar("VERSION");

--*******************************************************************************************
--initialzing ErrLog and gernerating Logfiles
--*******************************************************************************************

local Errlog = nil;

function ErrLogOpen()
    if(not Errlog) then
        local path = "";
        local backupname = "";
        local filename = "";
        if compare_versions(host_version,"3.1.3.0") then
           path = gma.show.getvar("TEMPPATH");
        else
           path = gma.show.getvar("PATH");
           path = path.."/temp";
        end

        backupname = path.."/lua_test_error_log_file.bak";
        filename = path.."/lua_test_error_log_file.malog";

       os.rename(filename,backupname);

       Errlog = assert(io.open(filename,'w'));
       Errlog:write("-------------------------------------------------------------------------------");
       Errlog:write("\nLUA Test Log. Version: " .. lua_test_version .. ". File created at " .. os.date('%Y-%m-%d %H:%M:%S'));
       Errlog:write("\nHost OS: " .. gma.show.getvar("OS") .. " Version: " .. host_version ..". Hostsystem type: " .. gma.show.getvar("HOSTTYPE") .. ". Hostsystem IP: " .. gma.network.getprimaryip())
       Errlog:write("\nThe following commads where executed while running the LUA Tests");
       Errlog:write("\n-------------------------------------------------------------------------------\n\n");
       -- install hooks:
       C = ErrlogCmd;
       F = ErrlogFeedback;
   end
end

--*******************************************************************************************
-- Hooks
--*******************************************************************************************

function ErrlogCmd(text,color)
    local result = doCMD(text, color);
    if(Errlog) then
        Errlog:write(text);
        Errlog:write('\n');
    end
    return result;
end

function ErrlogFeedback(text,color)
    if color then
        gma.feedback(text,color);
    else
        gma.feedback(text);
    end
    if(Errlog) then
        Errlog:write(text);
        Errlog:write('\n');
    end
end

function doCMD(text)
    local result = nil;
    if debug == true then
        for command in string.gmatch(text, '([^;]+)') do
            local res = gma.gui.confirm("Debug Break","CMD: "..command);
            if not res then
                cancel = true;
            else
                result = gma.cmd(command);
            end
        end
    else
        result = gma.cmd(text);
    end
    return result;
end

--*******************************************************************************************
-- Write ErrLog to file
--*******************************************************************************************

function ErrLogClose()
    if(Errlog) then
        Errlog:close();
        Errlog = nil;
        -- restore hooks to original
        C = doCMD;
        F = gma.feedback;
    end
end

--*******************************************************************************************
-- Properties Loader
-- is executed from init_fixtures.lua -> no more needed with static testshow
-- uses the information from property.xml for setting up the physical testobjects
-- uses the information from properties.xml for declaring the values for lua tests
-- setting up fixture_count and channel_count
--*******************************************************************************************

function loadProperties()
    local properties = {};
    if compare_versions(host_version,"3.1.3.0") then
         properties = gma.import("property.xml","plugins/systemtests/other");
         if dev then
            E("Loaded Properties...");
            E('Properties: ');
            E("Version: " .. properties.version);
            E("GS: " .. tostring(properties.golden_samples));
            E("Server: " .. tostring(properties.server));
            if properties.ignore then
                for i = 1, #properties.ignore do
                    E("Ignore " .. i .. ": " .. properties.ignore[i]);
                end
            end
            for i = 1, #properties.fixtures do
                E("Fixture " .. i .. ": " .. properties.fixtures[i]);
            end
            if properties.fixture_channel_count then
                for i = 1, #properties.fixture_channel_count do
                    E("Fixture " .. i .. " has: " .. properties.fixture_channel_count[i] .. " channels.");
                end
            else
                E("Fixture-channel-count not found.");
                for i = 1, #properties.fixtures do
                    properties.fixture_channel_count[i] = -1;
                end
            end
            for i = 1, #properties.fixture_count do
                E("Count " .. i .. ": " .. properties.fixture_count[i]);
            end
            if compare_versions(host_version,"3.1.0.0") then
                gma.sleep(2);
            else
                coroutine.yield(2);
            end
         end
    else
        --only needed in older versions
        local path = gma.show.getvar("PATH");
        local file = assert(io.open(path .. "/plugins/systemtests/other/properties.xml","r"));
        local result = file:read("*all");
        file:close();
        -- Parsing result
        local beginnings = {};
        local endings = {};
        if result then
            -- find the xml blocks------- find the xml blocks not nessessary with gma.import    local i = 0;
            while true do
              i = string.find(result, "<", i+1)    -- block beginnings
              if i == nil then
                --E("Found " .. #beginnings .. " '<'")
                break
              end
              table.insert(beginnings, i)
            end
            i = 0;
            while true do
              i = string.find(result, ">", i+1)    -- block endings
              if i == nil then
                 --E("Found " .. #endings .. " '>'")
                 break
              end
              table.insert(endings, i);
            end
            -- if blocks found
            if #beginnings > 0 and #endings > 0 then
                local blockcount = #beginnings;
                --E(blockcount);
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
                                    --E("removed space on key");
                                    key = string.sub(key,0,#key-1);
                                end
                                if string.find(value," ") then
                                    --E("removed space on value");
                                    value = string.sub(value,2,#value);
                                end
                                if dev then
                                    E("Detected Key " .. key .. " with value " .. value);
                                end
                                -- Insert property into the table
                                table.insert(properties,key);       --by key
                                table.insert(properties,value);     --by value
                                loaded = loaded+1;
                            else
                                E("No value assiged to property: ".. currentblock);
                            end
                        else
                            -- end of list
                            E("Loaded " .. loaded .. " porperties sucessfully.");
                            if dev then
                                E('sleeping for 2 sec.');
                                gma.sleep(2);
                            end
                            break;
                        end
                    end
                else
                    E("No 'Prop'-Block found. File seems to be invalid!");
                end
            else
                E("No Blocks found. File seems to be invalid!");
            end
        end
    end
    return properties;
end
--*******************************************************************************************
-- Properties interpreter
-- is executed from init_fixtures
--*******************************************************************************************

--version check
function check_prop_vers(properties)
    local version_value = -1;
    if compare_versions(host_version,"3.1.3.0") then
        -- Using gma.import();
        if properties.version then
            version_value = properties.version;
        end
    else
        if properties[0] == "version" then
            version_value = properties[1];
        end
    end

    if not version_value == -1 then
        if version_value == lua_test_version then
            return true;
        else
            E('Matrix version and Properties Version are not equal! Using Properies Version...');
            lua_test_version = version_value;
            return true;
        end
    end
    return false;
end

--Golden Samples will be created as .xml flag is set
function set_prop_gs(properties)
    local gs_value = -1;
    if compare_versions(host_version,"3.1.3.0") then
        -- Using gma.import();
        if properties.golden_samples then
            gs_value = properties.golden_samples;
        else
            if dev then
                F("Can't find XML-GS-Flag");
            end
        end
    else
        if properties[2] == "golden_samples" then
            if properties[3] == "true" then
                gs_value = true;
            else
                gs_value = false;
            end
        end
    end
    --setting create_missing_golden_samples by checking if value is empty or true
    if not gs_value == -1 then
        local state = 0;
        if gs_value == "true" then
            state = 1;
        end
        create_missing_golden_samples = state;   --set to not damage the golden show file-----state=0 gs are already existing, state=1 gs should be created
    end
end

function set_prop_server(properties)
    if compare_versions(host_version,"3.1.3.0") then
        -- Using gma.import();
        if properties.server then
            if dev then
                F('XML-Server-Flag: ' .. tostring(properties.server));
            end
            server = properties.server;
            ask_every_single_time = not server;
            if dev then
                F('Server-Flag is: ' .. tostring(server));
            end
        else
            if dev then
                F("Can't find XML-Server-Flag");
            end
        end
    else
        local server_value = -1;
        if properties[11] == "server" then
            if properties[12] == "true" then
                server_value = true;
            else
                server_value = false;
            end
        end

        if not server_value == -1 then
            if dev then
                F('Internal-Server-Flag: ' .. tostring(server_value));
            end
            ask_every_single_time = not server_value;
            server = server_value;
            if dev then
                F('Server-Flag is: ' .. tostring(server));
            end
        end
    end
end

function set_prop_destructive(properties)
    if compare_versions(host_version,"3.1.3.0") then
        -- Using gma.import();
        if properties.do_destructive then
            --if dev then
                F('XML-Destructive-Flag: ' .. tostring(properties.do_destructive));
            --end
            destructive_flag = properties.do_destructive;
        else
            --if dev then
                F("Can't find XML-Destructive-Flag");
            --end
        end
    else
        F("The destructive_flag is not supported for sw-versions lower 3.1.3.0.");
    end
end

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
                            E("Found " .. #pos .. " attributes");
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
                                --E("removed comma");
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

function get_prop_fixturetypes(properties)
    local ft = 0;
    if compare_versions(host_version,"3.1.3.0") then
        -- Using gma.import();
        ft = properties.fixtures;
    else
        if properties[5] == "fixtures" then
            if string.find(properties[6],"{") then
                ft = { };
                local pos = { };
                table.insert(pos, 2); -- Cut '{'
                gma.echo(properties[6]);
                i = 1;
                while true do
                    i = string.find(properties[6], ",", i+1);    -- number blocks
                    if i == nil then
                        gma.echo("Found " .. #pos .. " attributes");
                        break;
                    end
                    table.insert(pos, i);
                end
                table.insert(pos, #properties[6]-1); -- Cut '}'
                if #pos > 2 then
                    for i = 1, #pos-1 do
                        local currentattr = string.sub(properties[6],pos[i],pos[i+1]);
                        while true do
                            local tmp = string.find(currentattr,',');
                            if tmp then
                                -- get if it is on te beginning or at the end
                                if tmp ==1 then
                                    currentattr = string.sub(currentattr,2,#currentattr);
                                else
                                    currentattr = string.sub(currentattr,1,#currentattr-1);
                                end
                                --gma.echo("removed comma");
                            else
                                break;
                            end
                        end

                        while true do
                            local tmp = string.find(currentattr,'"');
                            if tmp then
                                -- get if it is on te beginning or at the end
                                if tmp ==1 then
                                    currentattr = string.sub(currentattr,2,#currentattr);
                                else
                                    currentattr = string.sub(currentattr,1,#currentattr-1);
                                end
                                --gma.echo("removed quote");
                            else
                                break;
                            end
                        end
                        table.insert(ft, currentattr);
                    end
                end
            else
                ft = properties[6];
            end
        end
    end
    return ft;
end

function get_prop_fixturechannelcount(properties)
    local fcc;
    if compare_versions(host_version,"3.1.3.0") then
        -- Using gma.import();
        fcc = properties.fixture_channel_count;
    else
        if properties[9] == "fixtures_channel_count" then
            if string.find(properties[10],"{") then
                fcc = { };
                local pos = { };
                table.insert(pos, 2); -- Cut '{'
                i = 1;
                while true do
                    i = string.find(properties[10], ",", i+1);    -- number blocks
                    if i == nil then
                        if dev then
                            gma.echo("Found " .. #pos .. " attributes");
                        end
                        break;
                    end
                    table.insert(pos, i);
                end
                table.insert(pos, #properties[10]-1); -- Cut '}'
                if #pos > 2 then
                    for i = 1, #pos-1 do
                        local currentattr = string.sub(properties[10],pos[i],pos[i+1]);
                        while true do
                            local tmp = string.find(currentattr,',');
                            if tmp then
                                -- get if it is on te beginning or at the end
                                if tmp ==1 then
                                    currentattr = string.sub(currentattr,2,#currentattr);
                                else
                                    currentattr = string.sub(currentattr,1,#currentattr-1);
                                end
                                --gma.echo("removed comma");
                            else
                                break;
                            end
                        end
                        table.insert(fcc, tonumber(currentattr));
                    end
                end
            else
                fcc = properties[10];
            end
        end
    end
    return fcc;
end

function get_prop_fixturenames(properties)
    local fn = { };
    if compare_versions(host_version,"3.1.3.0") then
        -- Using gma.import();
        for i = 1, #properties.fixtures do
            local pos = { };
            local j = 1;
            while true do
                j = string.find(properties.fixtures[i], "@", j+1);    -- number blocks
                if j == nil then
                    break
                end
                table.insert(pos, j);
            end
            if #pos > 1 then
                for j = 1, #pos-1, 2 do
                    local currentattr = string.sub(properties.fixtures[i],pos[j]+1,pos[j+1]-1);
                    table.insert(fn, currentattr);
                end
            end
        end
    else
        if properties[5] == "fixtures" then
            local pos = { };
            local j = 1;
            while true do
                j = string.find(properties[6], "@", j+1);    -- number blocks
                if j == nil then
                    gma.echo("Found " .. #pos/2 .. " fixturetype(s)");
                    break
                end
                table.insert(pos, j);
            end
            if #pos > 1 then
                for j = 1, #pos-1, 2 do
                    local currentattr = string.sub(properties[6],pos[j]+1,pos[j+1]-1);
                    table.insert(fn, currentattr);
                end
            end
        end
    end
    return fn;
end

function set_prop_server_spec(properties)
    local server_value = -1;
    if compare_versions(host_version,"3.1.3.0") then
        -- Using gma.import();
        if properties.server then
            server_value = properties.server;
        end
    else
        if properties[11] == "server" then
            if properties[12] == "true" then
                server_value = true;
            else
                server_value = false;
            end
        end
    end

    if not server_value == -1 then
        ask_every_single_time = not server_value;
        server_nc = server_value;
    end
end

function get_prop_fixturenames(properties)
    local fn = { };
    if compare_versions(host_version,"3.1.3.0") then
        -- Using gma.import();
        for i = 1, #properties.fixtures do
            local pos = { };
            local j = 1;
            while true do
                j = string.find(properties.fixtures[i], "@", j+1);    -- number blocks
                if j == nil then
                    break;
                end
                table.insert(pos, j);
            end
            if #pos > 1 then
                for j = 1, #pos-1, 2 do
                    local currentattr = string.sub(properties.fixtures[i],pos[j]+1,pos[j+1]-1);
                    table.insert(fn, currentattr);
                end
            end
        end
    else
        if properties[5] == "fixtures" then
            local pos = { };
            local j = 1;
            while true do
                j = string.find(properties[6], "@", j+1);    -- number blocks
                if j == nil then
                    E("Found " .. #pos/2 .. " fixturetype(s)");
                    break;
                end
                table.insert(pos, j);
            end
            if #pos > 1 then
                for j = 1, #pos-1, 2 do
                    local currentattr = string.sub(properties[6],pos[j]+1,pos[j+1]-1);
                    table.insert(fn, currentattr);
                end
            end
        end
    end
    return fn;
end

function check_ignore(properties, method_name,object_name)
    local ignored_methods = { };
    if compare_versions(host_version,"3.1.3.0") then
        -- Using gma.import();
        ignored_methods = properties.ignore;
    else
        if properties[11] == "ignore" then
            if string.find(properties[12],"{") then
                local pos = { };
                table.insert(pos, 2); -- Cut '{'
                i = 1;
                while true do
                    i = string.find(properties[12], ",", i+1);    -- number blocks
                    if i == nil then
                        if dev then
                            E("Found " .. #pos .. " attributes");
                        end
                        break;
                    end
                    table.insert(pos, i);
                end
                table.insert(pos, #properties[12]-1); -- Cut '}'
                if #pos > 1 then
                    for i = 1, #pos-1 do
                        local currentattr = string.sub(properties[12],pos[i],pos[i+1]);
                        while true do
                            local tmp = string.find(currentattr,',');
                            if tmp then
                                -- get if it is on the beginning or at the end
                                if tmp == 1 then
                                    currentattr = string.sub(currentattr,2,#currentattr);
                                else
                                    currentattr = string.sub(currentattr,1,#currentattr-1);
                                end
                                --E("removed comma");
                            else
                                break;
                            end
                        end
                        table.insert(ignored_methods, currentattr);
                    end
                end
            else
                ignored_methods = properties[12];
            end
        end
    end

    if dev then
        F("Ignore Check...");
    end

    if ignored_methods then
        if #ignored_methods > 0 then
            if dev then
                F("Looking for: " .. method_name .. "_" .. object_name);
            end
            for i=1, #ignored_methods do
                if dev then
                    --F("Found actually: " .. ignored_methods[i]);
                end
                if string.find(ignored_methods[i], method_name .. "_" .. object_name) then
                    if dev then
                        F("This method will be ignored");
                    end
                    return true;
                end
            end
        else
            if dev then
                F('No ignore entrys available');
            end
        end
    else
        if dev then
            F('No ignore entry available');
        end
    end
    return false;
end

function check_destructive(properties, method_name,object_name)
    local destructive_methods = { };
    if compare_versions(host_version,"3.1.3.0") then
        -- Using gma.import();
        if properties.destructive then     --ignored tests from the destructive table
            destructive_methods = properties.destructive;
        else
            --if dev then
                F("Can't find XML-Destructives-List");
            --end
        end
    else
        F("Destructive checks are not supported for sw-versions lower 3.1.3.0.");
    end

    if dev then
        F("Destructive Check...");
    end

    if destructive_methods then
        if #destructive_methods > 0 then
            if dev then
                F("Looking for: " .. method_name .. "_" .. object_name);
            end
            for i=1, #destructive_methods do
                if dev then
                    --F("Found actually: " .. destructive_methods[i]);
                end
                if string.find(destructive_methods[i], method_name .. "_" .. object_name) then
                    if dev then
                        F("This method is classified as destructive");
                    end
                    return true;
                end
            end
        else
            if dev then
                F('No destructive entries available');
            end
        end
    else
        if dev then
            F('No destructive entries available');
        end
    end
    return false;
end

function check_debug(properties, method_name,object_name)
    local debug_methods = { };
    if compare_versions(host_version,"3.1.3.0") then
        -- Using gma.import();
        if properties.debug then
            debug_methods = properties.debug;
        else
            if dev then
                F("Can't find XML-Debug-List");
            end
        end
    else
        F("Debug checks are not supported for sw-versions lower 3.1.3.0.");
    end

    if dev then
        F("Debug Check...");
    end

    if debug_methods then
        if #debug_methods > 0 then
            if dev then
                F("Looking for: " .. method_name .. "_" .. object_name);
            end
            for i=1, #debug_methods do
                if dev then
                    --F("Found actually: " .. debug_methods[i]);
                end
                if string.find(debug_methods[i], method_name .. "_" .. object_name) then
                    if dev then
                        F("This method will run in debug mode");
                    end
                    return true;
                end
            end
        else
            if dev then
                F('No debug entries available');
            end
        end
    else
        if dev then
            F('No debug entries available');
        end
    end
    return false;
end

--*******************************************************************************************
--starting the test frame
--*******************************************************************************************

local test_main_matrix={ n_methods=0; };

local registerdTests = 0;

local executedTests = 0;

--*******************************************************************************************
-- prototype for any generic test
--*******************************************************************************************

local test_prototype=
{
    method_name        = "UNKNOWN";
    object_name        = "UNKNOWN";
    test_type          = "golden_sample";    --only for 'function'
    gs_name            = nil;
    version_script     = nil;
    yield              = nil;
    pre                = nil;
    gold               = nil;                --positions are manually set in the single skript

    -----------------------------------------------------------------------------------------

    do_prepare = function (self)
        local errMsg;
        if(self.pre) then
            errMsg = C(self.pre);
        end
        if(errMsg) then
            if(dev) then
                errMsg = "CMD-Error: " .. errMsg;
                E(errMsg);
            end
            return errMsg;
        end
    end;

    -----------------------------------------------------------------------------------------

    name = function(self)
        return self.method_name .. "_" .. self.object_name;
    end;

    -----------------------------------------------------------------------------------------

    steps= { };
};

--*******************************************************************************************
-- helpfunction to increment a dotted number
--*******************************************************************************************

function IncrementDottedNumber(number)
   if(type(number) == "string") then                                            -- abfrage ob nummer ein string
      local last_dot = string.find(number,".",-1);                              -- suchen nach dem punkt
      if(last_dot ~= nil) then                                                  -- wenn punkt gefunden
         local last_number_string = string.sub(number,last_dot+1);              -- string.sub(src,start_value,[stop_value])   [] => optional syntetisiert die nummer nach dem punkt
         local last_number = tonumber(last_number_string);                      -- konvertieren des strings in eine nummer
         if(last_number ~= nil) then                                            -- wenn nummer vorhanden
            number = string.sub(number,1,last_dot) .. (last_number+1);          -- speichert in number die uhrsprüngliche variable bis einschließlich dem punkt und hängt die syntetisierte zahl plus 1 an
         end
      end
   else                                                                         -- wenn punkt nicht gefunden
      if(type(number) == "number") then                                         -- suchen nach nummer statt string
         number = number+1;                                                     -- inkrementieren der nummer
      end
   end
   return number;
end

--*******************************************************************************************
-- prototype for any step of a test
--*******************************************************************************************

local step_prototype=
{
    pre_func         = nil; -- function as preperation
    pre              = nil; -- preparation text
    cmd              = "";  -- tested episode of commads
    cmd_func         = nil; -- function as command
    post_func        = nil; -- function as post
    post             = nil; -- post text
    cleanup          = nil; -- cleanup text
    cleanup_func     = nil; -- function as cleanup
     exit_cmd         = nil; -- Does one last command if an error occurs and the script aborts

    version_step     = nil; -- Shows if step is executable with this version
    gs_name_step     = nil;
    test             = nil;
    test_dmx         = nil;
    blacktest        = false;

    smoketest        = false;   --test without copying, golden sample, comparison
    result           = nil;     --for tests of type function
    destructivetest  = false;   --warns if single tests are executed witch damaged the showfile


    -----------------------------------------------------------------------------------------
    -- executing pre commands
    -----------------------------------------------------------------------------------------

    do_prepare = function (self)
        local errMsg;
        if(self.pre) then
            errMsg = C(self.pre);
        end
        if(self.pre_func) then
            self.pre_func();
        end

        if(errMsg) then
            errMsg = "CMD-Error: " .. errMsg; --doing cleanup by breaking up;
            if(dev) then
                E(errMsg);
            end
            return errMsg;
        end
    end;

    -----------------------------------------------------------------------------------------
    -- executing cmd commands and gives command for DMXSnapshot
    -----------------------------------------------------------------------------------------

    do_test = function (self)
        local errMsg = nil;
        if(self.cmd) then                                   --executing command of cmd =
            errMsg = C(self.cmd);
        end

        if(self.cmd_func) then                              --if command of cmd is a function
            self.cmd_func();
        end

        if(errMsg) then
            errMsg = "CMD-Error: " .. errMsg;
            if(dev) then
                E(errMsg);
            end
            return errMsg;
        end

        if(self.test_dmx) then                              --if the DMXsnapshot is selected for the comparison in the single script -> test_dmx = true;
            G.verify(G.handle("SELECTION"));
            G.verify(G.handle("PROGRAMMER"));
            gma.sleep(2);                                   --important for getting a vaild DMXframe
            C("STORE DMXSNAPSHOT "..self.test);             --command for storing the DMXSnapshot at the position for comparison
        end

        if(self.smoketest) then                             --feedback msg for smoketest, meaning this single test is executed for testing of console crash without comparing gs values
            F("THIS IS A SMOKE TEST!");
        end

        if(self.destructivetest) then                       --feedback msg for executing destructive single test
            F("DESTRUCTIVE TEST!");
        end
    end;

    -----------------------------------------------------------------------------------------
    -- executing post commands
    -----------------------------------------------------------------------------------------

    do_post = function (self)
        local errMsg;
        if(self.post) then
            return C(self.post);
        end
        if(self.post_func) then
        self.post_func();
        end

        if(errMsg) then
            errMsg = "CMD-Error: " .. errMsg;
            if(dev) then
                E(errMsg);
            end
            return errMsg;
        end
    end;

    -----------------------------------------------------------------------------------------
    -- tests of type function
    -----------------------------------------------------------------------------------------

    compound = function(self)
        if not self.result() then
            return "Compound Error: Function test failed";
        end
    end;

    -----------------------------------------------------------------------------------------
    -- single or tables of GoldenSamples
    -----------------------------------------------------------------------------------------

    do_verify = function (self, verify_param)
        local gs_res = nil;
        local result_text = nil;
        if(type(self.test) == "number") then                    -- if a single Golden Sample is existing do_verify_single_index
            result_text, gs_res = self:do_verify_single_index(verify_param,1,self.test);
            return result_text, gs_res;
        else
            if(type(self.test) == "table") then                 -- if the comparison should handle a table of values {x,y}
                    for i , test_index in ipairs(self.test) do
                    result_text = nil;
                    gs_res = nil;
                    result_text, gs_res = self:do_verify_single_index(verify_param,i,test_index);
                    if (result_text) then
                        return result_text, gs_res;
                    end
                end
            end
        end
    end;

    -----------------------------------------------------------------------------------------
    -- processing of the script (Interpreter)
    -----------------------------------------------------------------------------------------

    do_verify_single_index = function (self,verify_param,gold_offset,test_index)
        local ON = nil;                                              -- Variable ON => Objectname
        local ON2 = nil;
        local errMsg = nil;
        local fwd = false;

        if dev then                                                  -- type checking
            if(not type(test_index) == string) then
                F('Error (3): Type of test_index is illegal');
                return false;
            end
            if(not type(verify_param) == string) then
                F('Error (4): Type of verify_param is illegal');
                return false;
            end
        end

        if(self.test_dmx) then
            ON = "DMXSNAPSHOT";                     --comparison for DMXsnapshot
        else
            ON = self.object_name;                  --comparison for object name, defines what is to compare, except cueparts
        end

        if(ON == "CUEPART") then                    -- ON2 for Cue Parts
            ON2 = "CUE 2 PART";
            --if(dev) then
                E("Using for golden sample on2 = CUE 2 PART");
            --end
        end

        if self.gs_name_step then
            ON=self.gs_name_step;                   -- going for alternative objectname
            if dev then
                F('Found alternative Objectname: ' .. ON);
            end
        end

        if(self.gold) then                                                          --@gold: position of the verification object
            if(type(self.gold) == "number" or type(self.gold) == "string") then
                verify_param.gold = self.gold;                                      --@verify_param.gold: golden handle, the compart
            else
                if(type(self.gold) == "table") then                                 --gs as table --gold={x,y}
                    local table_width = #self.gold;
                    gold_offset = gold_offset%table_width;
                    if(gold_offset == 0) then                                       -- resetting of "gold_offset" by reaching the last element
                        gold_offset = table_width;
                    end
                    verify_param.gold = self.gold[gold_offset];                     -- storing of the current element in "verify_param.gold"
                end
            end
        end

        local handle = G.handle(ON .. " "..test_index);                               --handle of the test object
        local golden_handle = nil;

        if(tonumber(verify_param.gold) > 0) then                                      --if golden handle is available
            if dev then
                if(ON2) then
                    F("Handle-Request:" ..  ON2 .. " "..verify_param.gold);
                else
                    F("Handle-Request:" ..  ON .. " "..verify_param.gold);
                end
            end
            if(ON2) then                                                                 --ON2 for Cueparts
            golden_handle = G.handle(ON2 .. " "..verify_param.gold);
            else
            golden_handle = G.handle(ON .. " "..verify_param.gold);                      --everything but cueparts
            end
        else                                                                             --no golden handle, comparison with empty position
            golden_handle = nil;
            F('Verification Process to an empty object...');
            if(G.compare(handle,golden_handle) == self.blacktest) then                   --comparision from C++ is called
                if(self.blacktest) then
                    return "black comparison with an empty object";
                else
                    return "golden comparison with an empty object";
                end
            else
                fwd = true;
            end
        end

        if(dev) then
            if(handle) then
                F("Got my Handles. " .. "Testobject:    " .. handle);                       --watching handles -> handle of the test object is always set new, handle of the gs must stay the same
                F("Testindex: ".. test_index);
            else
                F("Handle is nil!" .. " Testindex: ".. test_index);
            end
            if(golden_handle) then
                F("                " .. "Golden Sample: " .. golden_handle);
            else
                if(verify_param.gold) then
                    F("Golden handle is nil! " .. "Goldindex: ".. verify_param.gold);
                end
            end
        end

        local gs_res = nil;
        if(handle and not fwd) then                                                          -- C++ <=> LUA     ! <=> not    && <=> and
            if(not golden_handle) then                                                       -- if no golden sample exist
                if (create_missing_golden_samples and not blacktest) then
                    if ask_every_single_time and not host_version == "3.1.2.5" then
                        gs_res = gma.gui.confirm("LUA Processing", "Do you want to create a golden sample for " .. self:name() .. "?");
                    else
                        gs_res = true;
                    end
                    if gs_res then
                        --E("This is used in the Golden Show File. ");
                        F("Trying to create my own golden sample");
                        if ON == "CUE" then
                           if dev then
                               F('Creating Golden Sample silent...');                                                 --verify_param.gold is the golden handle
                            end                                                                                       --copy the object to golden sample for verifying, only if the position is empty
                            errMsg = C("COPY  ".. ON .. " " .. test_index .. " AT " .. verify_param.gold .. " /nc");  --cues, /nc is needed for questioning cueonly or status
                        else
                            if self.object_name == "CUEPART" then
                                errMsg = C("COPY  ".. ON .. " " .. test_index .. " AT " .. ON2 .. " " .. verify_param.gold .. " /nc");   --cueparts, /nc is needed for questioning cueonly or status
                            else
                               errMsg = C("COPY  ".. ON .. " " .. test_index .. " AT " .. verify_param.gold);   --everything but cues or cueparts
                            end
                        end
                        if self.object_name == "CUEPART" then
                            C("LABEL ".. ON2 .. " " .. verify_param.gold .. " " .. '"' .. self:name() ..'"');   --cueparts
                        else
                            C("LABEL ".. ON .. " " .. verify_param.gold .. " " .. '"' .. self:name() ..'"');    --everything but cues or cueparts
                        end

                        if(errMsg) then
                            if(dev) then
                                E("CMD-Error: " .. errMsg);
                            end
                            return "Abort by user", gs_res;
                        end
                    end
                end
                                                                                                        --handle is unique, by reloading the handle is set new, golden handle is static
                if(ON2) then                                                                            --verify_param.gold has to be a firm position, set in the single script
                    golden_handle = G.handle(ON2 .. " "..verify_param.gold);                            -- Golden Samples galready exist
                else
                    golden_handle = G.handle(ON .. " "..verify_param.gold);
                end

                if(not golden_handle) then                                                               -- checking for golden handle
                    if(ON2) then
                        return "golden " .. ON2 .. " " .. verify_param.gold .. " not found", gs_res;
                    else
                        return "golden " .. ON .. " " .. verify_param.gold .. " not found", gs_res;
                    end
                end
            end
        end

        F('Verification Process...');                                                                      --comparison between handle of test object and golden handle
        gma.sleep(0.2);
            if(G.compare(handle,golden_handle) == self.blacktest) then                                     -- G.compare calls extern comparison (in C++ [LUA_API])
                if(self.blacktest) then
                    return "black comparison failed", gs_res, self:do_cleanup();
                else
                    return "golden comparison failed", gs_res, self:do_cleanup();                          --cleanup for failed tests!!
                end
            end

    end;

    -----------------------------------------------------------------------------------------
    -- executing cleanup command
    -- after performing a single test script, even it's failed or exits with an error, a cleanup must be done
    -----------------------------------------------------------------------------------------

    do_cleanup = function (self)
    local errMsg;
    local cleanMsg;
        if(self.cleanup_func) then
        self.cleanup_func();
        end
        if(self.cleanup) then
            errMsg = C(self.cleanup);  --executes the single scripts own cleanup
            cleanMsg = C('cd /; clearall; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');   --standard cleanup step for every test
        end

        if(errMsg) then
            if(dev) then
                E("CMD-Error: " .. errMsg);
            end
            return errMsg, cleanMsg;
        end
    end;

    -----------------------------------------------------------------------------------------
    -- Executing exit command
    -----------------------------------------------------------------------------------------
    do_exit = function (self)
        local errMsg;
        if(self.exit_cmd) then
            E('Executing exit commands because of an script error');
            errMsg = C(self.exit_cmd);
        end

        if(errMsg) then
            if(dev) then
                E("CMD-Error: " .. errMsg);
            end
            return errMsg;
        end
    end;

    -----------------------------------------------------------------------------------------
    -- sets method name
    -----------------------------------------------------------------------------------------

    name = function(self)
        return self.method_name .. "_" .. self.object_name .. " STEP ".. self.step_index;
    end;
};

-----------------------------------------------------------------------------------------
-- processing a version number
-----------------------------------------------------------------------------------------

get_version_numbers = function (vers)
    local s = {};
    if vers then
        local pos = {};
        table.insert(pos, 1);
        local i = 0;
        while true do
            i = string.find(vers, '%.', i+1);    -- number blocks
            if i == nil then
                --E("Found " .. #pos .. " numbers");
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
                        if tmp == 1 then
                            currentno = string.sub(currentno,2,#currentno);
                        else
                            currentno = string.sub(currentno,1,#currentno-1);
                        end
                        --E("removed point");
                    else
                        break;
                    end
                end
                table.insert(s, tonumber(currentno));
            end
        end
        if dev then
            local output = s[1] .. " " .. s[2] .. " " .. s[3];
            if s[4] then
                output = output .. " " .. s[4];
            end
            F(output);
        end
    else
       if dev then
         F("Can't find a version number!");
       end
    end
    return s;
end

-----------------------------------------------------------------------------------------
-- comparison of versions (number1 is Host)
-----------------------------------------------------------------------------------------

compare_versions = function (number1,number2)
    if dev then
        F('Comparing Versions...');
        if number1 then
            F('Host: ' .. number1 .. ' Version.');
        else
            F('Host: Unknown Version.');
        end
    end

    local n1 = get_version_numbers(number1);

    if number2 then
        if dev then
            F('Script/Step: ' .. number2 .. ' Version.');
        end
        local n2 = get_version_numbers(number2);
        -- Compare
        if n2 then
            for i=1,#n1 do
                if n1[i] < n2[i] then
                    return false;
                else
                    if n1[i] > n2[i] then
                        if dev then
                            F("Success!");
                        end
                        return true;
                    end
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
    end
    if dev then
        F("Success!");
    end
    return true;
end

function calcTime(time_sec)
    local result;
    if time_sec > 60 then
        local minutes = time_sec / 60;
        local seconds = time_sec % 60;
        result = math.floor(minutes) .. " min " .. math.floor(seconds) .. " sec";
    else
        result = math.floor(time_sec) .. " sec";
    end
    return result;
end

--*******************************************************************************************
-- every registered test gets this meta table
--*******************************************************************************************

local test_meta_table=
{
    __index= function(table,key)
        return test_prototype[key];
    end
};

local step_meta_table=
{
    __index= function(table,key)
        return step_prototype[key];
    end
};

--*******************************************************************************************
-- register a test script. This function is global
--*******************************************************************************************

function RegisterTestScript(test_script)
    setmetatable(test_script,test_meta_table);

    for step_index,step in ipairs(test_script.steps) do         --iterates over the steps in a script
        step.test_script = test_script;                         --single step is treaten like a single script
        step.method_name = test_script.method_name;
        step.object_name = test_script.object_name;
        step.step_index = step_index;
        setmetatable(step,step_meta_table);
    end

    local method=test_main_matrix[test_script.method_name];     --method which is tested, this script is fetched into the matrix
       if(not method) then
        method={ n_objects=0; };
        method.method_name = test_script.method_name;
        test_main_matrix[test_script.method_name] = method;      -- access by name
                test_main_matrix.n_methods = test_main_matrix.n_methods+1;
        test_main_matrix[test_main_matrix.n_methods] = method;   -- access by index
    end

    if(not method[test_script.object_name]) then
        method.n_objects = method.n_objects+1;

        registerdTests = registerdTests + 1;
    else
        F("WARNING : test script " .. test_script:name() .. " is double");
    end
    method[test_script.object_name] = test_script;                -- access by name
    method[method.n_objects] = test_script;                       -- access by index
end

--*******************************************************************************************
-- Indefier if a single script is started or the complete matrix
--*******************************************************************************************

local testmatrix_started = false;

--*******************************************************************************************
-- Run through the steps of a single test and report its errors
--*******************************************************************************************

function StartSingleTestScript(test_script)
    local amount = 1;                                   --amount of patched devices
    if not testmatrix_started then
        C('fixture thru; channel thru ');
        if compare_versions(host_version,"3.1.0.0") then
            amount = gma.show.getvar("SELECTEDFIXTURESCOUNT");
        else
            F("Can't get fixture Count... Version incompatible.");
            amount = 1;
        end
        F("Patched devices: " .. amount);
        if tonumber(amount) == 0 then
            local result = false;
            if server == true then
                result = true;
            else
                if host_version == "3.1.2.5" then
                    result = false;
                else
                    result = gma.gui.confirm("Initalize Showfile","There are no devices patched. Should your showfile be initialzed?");
                end
            end
            if result then
                yield = true;
                --C('Plugin ShowfileInit');                       --Plugin ShowfileInit is called
                local mytime = math.floor(gma.gettime());
                while yield do
                    local delta = gma.gettime() - mytime;
                    if delta > 2 then
                        E("Waiting");
                        mytime = gma.gettime();
                    end
                end
                C('fixture thru; channel thru ');
                amount = gma.show.getvar("SELECTEDFIXTURESCOUNT");
            else
                F('There are no devices patched. Test will be skipped!');
                if not host_version == "3.1.2.5" then
                    if compare_versions(host_version,"3.1.3.0") then
                        gma.gui.msgbox("Test-Script","There are no fixtures created to test with!");
                    else
                        gma.gui.confirm("Test-Script","There are no fixtures created to test with!");
                    end
                end
            end
        end
        prop = loadProperties();
        debug = check_debug(prop, test_script.method_name, test_script.object_name);
        if dev then
        end
            F("Debug: " .. tostring(debug));
    end
    local step_skips = { };

    if(test_script and tonumber(amount) > 0) then
        F('************************************');
        F("Performing test "..test_script:name());
        F('************************************');

        --if(writesingleErrLog) then
        --    OpenStepLog(test_script:Name());
        --end
        if compare_versions(host_version,test_script.version_script) then
            local return_text = "No Step Error.";
            local result_text = test_script:do_prepare();
            local return_cleanup = nil;
            if(result_text) then
                return_text = test_script:name() .. " SCRIPT_PREPARE ERROR : " .. result_text;
                F(return_text);
                C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');
                return false, return_text;
            else
                local verify_param = {};
                verify_param.gold=test_script.gold;                     --getting the position of the golden sample
                for step_index,step in ipairs(test_script.steps) do     --executing single steps
                    local res = true;
                    if test_script.gs_name then                         --gs_name only working for CUE
                        if dev then
                            F("Found alternative Script Objectname " .. test_script.gs_name);
                        end
                        if test_script.gs_name == "UNKNOWN" then
                        else
                            if step.gs_name_step == nil then
                                if dev then
                                    F("Set alternative Script Objectname " .. test_script.gs_name);
                                end
                                step.gs_name_step = test_script.gs_name;
                            else
                                if dev then
                                    F("Can't set alternative Script Objectname. Step Objectname is already defined.");
                                end
                            end
                        end
                    end
                    if step.version_step then
                        F(step:name() .. " Version check : Hostversion: " .. host_version .. " Step version: " .. step.version_step);
                        res = compare_versions(host_version,step.version_step);
                    end
                    if res then
                        result_text=step:do_prepare();
                        if(result_text) then
                            return_text = step:name() .. " PREPARE ERROR : " .. result_text;
                            F(return_text,"col_red");
                            return false, return_text;
                        else
                            result_text=step:do_test();
                            if(result_text) then
                                return_text = step:name() .." TEST ERROR : " .. result_text;
                                F(return_text,"col_red");
                                step:do_exit();
                                return false, return_text;
                            else
                                if(test_script.test_type == 'function') then -- function test
                                    result_text = step:compound();
                                else -- golden sample test
                                    local gs_res = nil;
                                    result_text, gs_res =step:do_verify (verify_param);
                                    if(result_text and step.blacktest) then
                                        F(step:name() .. " BLACKTEST VERIFY (That's good!): " .. result_text);
                                    end
                                    if(not result_text and step.blacktest) then
                                        F(step:name() .. " BLACKTEST VERIFY ERROR (".. verify_param.gold .. ")");
                                    end
                                    if not gs_res and ask_every_single_time then
                                        result_text = step:name() .. " FAIL: Skipped because Golden Sample wasn't created!";
                                        table.insert(step_skips,result_text);
                                        F(result_text);
                                    end
                                end
                                if(result_text and not step.blacktest) then
                                    if(test_script.test_type == 'function') then -- function test
                                        return_text = step:name() .. " " .. result_text;
                                    else -- golden sample test
                                        return_text = step:name() .. " VERIFY ERROR (".. verify_param.gold .. "): " .. result_text;
                                    end
                                    F(return_text,"col_red");
                                    step:do_exit();
                                    return false, return_text;
                                else
                                    result_text=step:do_post();
                                    if(result_text) then
                                        return_text = step:name() .. " POST ERROR : " .. result_text;
                                        F(return_text,"col_red");
                                        return_cleanup = step:do_cleanup();
                                        return false, return_text, return_cleanup;
                                    else
                                        result_text=step:do_cleanup();
                                        if(result_text) then
                                            return_text = step:name() .. " CLEANUP ERROR : " .. result_text;
                                            F(return_text,"col_red");
                                            step:do_exit();
                                            return false, return_text;
                                        else

                                            if verify_param.gold then                               --comparison successful
                                                F(step:name() .. " PASSED (" .. verify_param.gold .. ")");
                                                --step:do_cleanup();
                                            else
                                                F(step:name() .. " PASSED");
                                                --step:do_cleanup();
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    else
                        result_text = step:name() .. ": Version SKIP : Stepversion isn't compatible with Host System. Step will be skipped.";
                        table.insert(step_skips,result_text);
                        F(result_text);
                    end
                end
            end
        else
            result_text = test_script:name() .. ": Version SKIP : Scriptversion isn't compatible with Host System. Script will be skipped.";
            table.insert(step_skips,result_text);
            F(result_text);
        end

        --if(writesingleErrLog) then
        --    CloseStepLog();
        --end
    else
        return_text = "StartSingleTestScript ERROR : No script. Script might be skipped."
        F(return_text);
        return false , return_text;
    end

    if step_skips and #step_skips > 0 then
        F("step_skips: ");
        for i = 1, #step_skips do
            F(step_skips[i]);
        end
    end

    return true, return_text, step_skips;
end

--*******************************************************************************************
-- Run through all registered tests in a nice loop
--*******************************************************************************************

local method_progress = nil;
local object_progress = nil;
local ignore = false;
local prop = nil;

local function StartAllTestScripts(oldtime)
    -- reset cancel
    cancel = false;
    -- Check if fixtures available to test with
    local starttime = gma.gettime();
    if oldtime then
        starttime = oldtime;
    end

    C('fixture thru; channel thru ');
    local amount = 0;
    if compare_versions(host_version,"3.1.0.0") then
        amount = gma.show.getvar("SELECTEDFIXTURESCOUNT");
    else
        F("Can't get fixture Count... Version incompatible.");
        amount = 1;
    end

    ErrLogOpen();
    F("Registered Tests: "..registerdTests);
    F("Patched devices: " .. amount);
    prop = loadProperties();
    set_prop_gs(prop);
    if dev then
        F("Golden-Samples-Flag is: " .. tostring(create_missing_golden_samples));
    end
    for i = 1, #serverIPs do
        if gma.network.getprimaryip() == serverIPs[i] then
            server = true;
            break;
        end
    end
    if dev then
        F("Server-Flag is: " .. tostring(server));
    end
    set_prop_destructive(prop);
    if dev then
        F("Destructive-Flag is: " .. tostring(destructive_flag));
    end
    local script_errors = 0; local script_error_messages = { }; local scripts = 0; local script_skips = 0; script_skip_method_names = { }; total_other_skips = { };
    if tonumber(amount) > 0 then
        testmatrix_started = true;
        yield2 = true;
        C('Plugin "Gen Importfiles"');
        local mytime = math.floor(gma.gettime());
        while yield2 and not cancel do
            local delta = gma.gettime() - mytime;
            if delta > 2 then
                E("Waiting");
                mytime = gma.gettime();
            end
        end
        F('*******************************************************************************************');
        F("Starting main test matrix");
        F('*******************************************************************************************');
        if (create_missing_golden_samples) then
            F('Missing golden samples will be auto created!!!');
        end
        method_progress = gma.gui.progress.start("Method");
        gma.gui.progress.setrange(method_progress,1,test_main_matrix.n_methods);
        for method_index,method in ipairs(test_main_matrix) do               -- iterates over all methods (scripts)
            if cancel then
                F('Canceling...!');
                break;
            end
            if(method and type(method) == "table") then
                gma.gui.progress.set(method_progress,method_index);
                gma.gui.progress.settext(method_progress,method.method_name);
                F("Start testing method " .. method.method_name);
                object_progress=gma.gui.progress.start("Object");
                gma.gui.progress.setrange(object_progress,1,method.n_objects);
                for object_index,test_script in ipairs(method) do
                    if cancel then
                        F('Canceling...!');
                        break;
                    end
                    executedTests = executedTests + 1;
                    local result_test = false;
                    local error_text = nil;
                    local other_skips = nil;
                    if(test_script and type(test_script)=="table") then
                        gma.gui.progress.set(object_progress,object_index);
                        gma.gui.progress.settext(object_progress,test_script.object_name);
                        local ignore = check_ignore(prop, test_script.method_name, test_script.object_name);
                        local destructive = check_destructive(prop, test_script.method_name, test_script.object_name);
                        debug = check_debug(prop, test_script.method_name, test_script.object_name);
                        if dev then
                            F("Ignore Result: " .. tostring(ignore));
                            F("Destructive Result: " .. tostring(destructive));
                            F("Debug Result: " .. tostring(debug));
                        end
                        if not ignore and (not destructive or destructive_flag) then
                            result_test, error_text, other_skips = StartSingleTestScript(test_script);
                            if error_text and dev then
                                E(tostring(result_test) .. " " .. error_text);
                            end
                            if dev then
                                F('Yield Value: ' .. tostring(test_script.yield));
                            end
                            if test_script.yield then
                                if test_script.yield == true then
                                    --C('Plugin ShowfileInit');
                                    yield = test_script.yield;
                                    local mytime = math.floor(gma.gettime());
                                    while yield do
                                        local delta = gma.gettime() - mytime;
                                        if delta > 2 then
                                            E("Waiting");
                                            mytime = gma.gettime();
                                        end
                                    end
                                end
                            end
                        else
                            script_skips = script_skips + 1;
                            if destructive then
                                F('Script ' .. test_script:name() .. " is destructive. Script will be skipped.");
                                table.insert(script_skip_method_names, test_script:name() .. " (destructive)");
                            else
                                F('Script ' .. test_script:name() .. " will be skipped.");
                                table.insert(script_skip_method_names, test_script:name());
                            end
                        end
                        scripts = scripts + 1;
                    end
                    if ((not result_test and error_text) or (result_test == false and error_text)) then
                        script_errors = script_errors + 1;
                        table.insert(script_error_messages, error_text);
                    end
                    if other_skips then
                        for i = 1, #other_skips do
                            table.insert(total_other_skips,other_skips[i]);
                        end
                    end
                end
                gma.gui.progress.stop(object_progress);
                object_progress = nil;
            end
        end
        gma.gui.progress.stop(method_progress);
        method_progress = nil;
        F(executedTests.." tests of " .. registerdTests .. " done.");
        F('');
        F('Duration: ' .. calcTime(gma.gettime()-starttime));
        F('');
        if cancel then
            F('Test has been canceled. So far:');
        end
        if script_errors > 0 then
            F('Summary: ' .. script_errors .. ' of ' .. scripts .. ' Scripts in the Testmatrix failed!');
            for i = 1, #script_error_messages do
                F('    ' .. script_error_messages[i],"col_red");
            end
            F('');
        else
            F('    All Scripts in the Testmatrix succeed. No Errors!',"col_green");
            F('');
        end

        if not destructive_flag then
            F('    Destructive tests had been skiped.');
            F('');
        end

        if script_skips > 0 then
            F(script_skips .. ' of ' .. scripts .. ' Scripts were ignored:');
            for i = 1, #script_skip_method_names do
                F('    ' .. script_skip_method_names[i]);
            end
            F('');
        end

        if total_other_skips and #total_other_skips > 0 then
            local other_step_skips = 0;
            local other_script_skips = 0;
            for i = 1, #total_other_skips do
                if string.find(total_other_skips[i],"STEP") then
                    other_step_skips = other_step_skips + 1;
                else
                    other_script_skips = other_script_skips +1;
                end
            end
            F('Also the following ' .. other_step_skips .. ' Steps and ' .. other_script_skips .. ' Scripts were skipped:');
            for i = 1, #total_other_skips do
                F('    ' .. total_other_skips[i]);
            end
            F('');
        end
    else
        local result = false;
        if server == true then
            result = true;
        else
            if host_version == "3.1.2.5" then
                result = false;
            else
                result = gma.gui.confirm("Initalize Showfile","There are no devices patched. Should your showfile be initialzed?");
            end
        end

        if result then
            yield = true;
            --C('Plugin ShowfileInit');
            local mytime = math.floor(gma.gettime());
            while yield do
                local delta = gma.gettime() - mytime;
                if delta > 2 then
                    E("Waiting");
                    mytime = gma.gettime();
                end
            end
            StartAllTestScripts(starttime);
        else
            F('There are no devices patched. Test will be skipped!');
            if not host_version == "3.1.2.5" then
                if compare_versions(host_version,"3.1.3.0") then
                    gma.gui.msgbox("Test-Matrix-Error","There are no fixtures created to test with!");
                else
                    gma.gui.confirm("Test-Matrix-Error","There are no fixtures created to test with!");
                end
            end
        end
    end
end

--*******************************************************************************************
-- CleanUp function for this module
--*******************************************************************************************

local function CleanUp()
    if(method_progress) then
        gma.gui.progress.stop(method_progress);
        method_progress = nil;
    end
    if(object_progress) then
        gma.gui.progress.stop(object_progress);
        object_progress = nil;
    end
    F('Done');
    ErrLogClose();
    testmatrix_started = false;
    C('ClearAll; cd /');
    F("CleanUp Done");
    if server == true and not cancel then
        F('Sleeping 5 seconds before shutdown');
        gma.sleep(5);
        if not cancel then
            F('Shoutdown application....');
            C('shutdown /nc');  -- End GMA Server Application autmatically for server tests
        end
    end
end

--*******************************************************************************************
-- module entry point
--*******************************************************************************************

return StartAllTestScripts,CleanUp;