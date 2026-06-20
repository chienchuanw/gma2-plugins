-- ******************************************************************************************
-- The GMA2 LUA API
-- ******************************************************************************************
--                            gma.sleep(number:sleep_seconds)
--                            gma.echo(all kind of values)
--                            gma.feedback(all kind of values)
--
-- string:build_date        = gma.build_date()
-- string:build_time        = gma.build_time()
-- string:version_hash      = gma.git_version()
--
--                            gma.export(string:filename,table:export_data)
--                            gma.export_csv(string:filename,table:export_data)
--                            gma.export_json(string:filename,table:export_data)
-- table:import_data        = gma.import(string:filename, [string:gma_subfolder])
--
-- string:error             = gma.cmd(string:command)
--                            gma.timer(function:name,number:dt,number:max_count,[function:cleanup])
-- number:time              = gma.gettime()
-- string:result            = gma.textinput(string:title,[string:old_text])
--
-- bool:result              = gma.gui.confirm(string:title,string:message)
--                          = gma.gui.msgbox(string:title,string:message)
--
-- number:handle            = gma.gui.progress.start(string:progress_name)
--                            gma.gui.progress.stop(number:progress_handle)
--                            gma.gui.progress.settext(number:progress_handle,string:text)
--                            gma.gui.progress.setrange(number:progress_handle,number:from,number:to)
--                            gma.gui.progress.set(number:progress_handle,number:value)
--
-- number:value             = gma.show.getdmx(number:dmx_addr)
-- table:values             = gma.show.getdmx(table:recycle,number:dmx_addr,number:amount)
--
-- number:handle            = gma.show.getobj.handle(string:name)
-- string:classname         = gma.show.getobj.class(number:handle)
-- number:index             = gma.show.getobj.index(number:handle)
-- number:commandline_number= gma.show.getobj.number(number:handle)
-- string:name              = gma.show.getobj.name(number:handle)
-- string:label             = gma.show.getobj.label(number:handle)  returns nil if object has no label set
-- number:amount_children   = gma.show.getobj.amount(number:handle)
-- number:child:_handle     = gma.show.getobj.child(number:handle, number:index)
-- number:parent_handle     = gma.show.getobj.parent(number:handle)
-- bool:result              = gma.show.getobj.verify(number:handle)
-- bool:result              = gma.show.getobj.compare(number:handle1,number:handle2)
--
-- number:amount            = gma.show.property.amount(number:handle)
-- string:property_name     = gma.show.property.name(number:handle,number:index)
-- string:property          = gma.show.property.get(number:handle,number:index/string:property_name)
--
-- string:value             = gma.show.getvar(string:varname)
--                            gma.show.setvar(string:varname,string:value)
--
-- string:value             = gma.user.getvar(string:varname)
--                            gma.user.setvar(string:varname,string:value)
-- number:object handle     = gma.user.getcmddest()
-- number:object_handle     = gma.user.getselectedexec()
--
-- string:type              = gma.network.gethosttype()
-- string:subtype           = gma.network.gethostsubtype()
-- string:ip                = gma.network.getprimaryip()
-- string:ip                = gma.network.getsecondaryip()
-- string:status            = gma.network.getstatus()
-- number:session_number    = gma.network.getsessionnumber()
-- string:session_name      = gma.network.getsessionname()
-- number:slot              = gma.network.getslot()
--
-- table:host_data          = gma.network.gethostdata(string:ip,[table:recycle])
-- table:slot_data          = gma.network.getmanetslot(number:slot,[table:recycle])
-- table:performance_data   = gma.network.getperformance(number:slot,[table:recycle])

-- ******************************************************************************************
-- This is a test to check ever command to it's function and the console stability
-- ******************************************************************************************
local E = gma.echo; -- create fast shortcut for functionblock. this is speeding up the script significantly
local F = gma.feedback;
local C = gma.cmd;
local host_version = gma.show.getvar("VERSION");
local var_errors = {};

function API_Test()
    local result = nil;

    E("********************** Starting LUA API Test **********************");
    E("");
    E("Starting with print out some information to the cmd feddback...");
    -- string:build_date        = gma.build_date()
    -- string:build_time        = gma.build_time()
    -- string:version_hash      = gma.git_version()
    -- number:time              = gma.gettime()

    local command = {}; local text = {};
    command[1] = gma.build_date();     text[1] = "Build-Date";
    command[2] = gma.build_time();     text[2] = "Build-Time";
    command[3] = gma.git_version(); text[3] = "GIT-Version";
    command[4] = gma.gettime();     text[4] = "Current Time";
    printInfo(command,text);

    E("Finished");
    E(""); F("");
    E("Doing some sleep stuff...");
    --                            gma.sleep(number:sleep_seconds)

    -- If here is no crash then it's ok.
    for i = 1, 10 do
        local sleep_value = i*1;
        if (sleep_value > 0) then
            F("Sleeping the ".. i .. ". time. Now for " .. sleep_value/2 .. " seconds");
            --gma.sleep(sleep_value);
        end
    end

    E("Finished");
    E(""); F("");
    E("Testing some import/export stuff...");
    --                            gma.export(string:filename,table:export_data)
    --                            gma.export_csv(string:filename,table:export_data)
    --                            gma.export_json(string:filename,table:export_data)
    -- table:import_data        = gma.import(string:filename, [string:gma_subfolder])

    local exportTable = {"this", "is", "a", "test"};
    local importTable = nil;

    gma.export("api_test.xml",exportTable);
    gma.export_csv("api_test.csv",exportTable);
    gma.export_json("api_test.json",exportTable);

    importTable = gma.import("api_test.xml");

    -- import works only with xml exported data
    if(importTable) then
        F("Importet a '.xml' table with ".. #importTable .." entries.")
        for i=1, #importTable, 1 do
            F("Entry " .. i .. ": Exported: " .. exportTable[i]);
            F("Entry " .. i .. ": Imported: " .. importTable[i]);
        end
    else
        errors("gma.export and/or gma.import with xml");
    end

    E("Finished");
    E(""); F("");
    E("Testing some GUI stuff...");
    -- bool:result              = gma.gui.confirm(string:title,string:message)
    --                          = gma.gui.msgbox(string:title,string:message)

    if (type(host_version) == "string" and not (host_version == "3.1.2.5")) then
        -- Messageboxes are broken in 3.1.2.5

        -- Here is a coroutine necessary
        --[[co = coroutine.create(function ()
            F("Press");
            press_old();
        end)
        coroutine.resume(co);]]

        F("Spawning UI");
        local result = gma.gui.confirm("This is a test", "I just opend for you a modal window!|Please click OK.");
        if not(result) then
            errors("gma.gui.confirm");
        end
    end
    -- gma.gui.msgbox were added in 3.2.1 and is not downwards compatible
    if tonumber(string.sub(host_version,3,3)) > 1 then
        gma.gui.msgbox("This is a test", "I just opend for you a non-modal window!|This will auto close in a second.");
        F("Sleeping a second...");
        gma.sleep(1);
        press_old();
    else
        F("Hostversion is to low to perform gma.gui.msgbox()");
    end

    E("Also Testing some timers stuff...");
    --                            gma.timer(function:name,number:dt,number:max_count,[function:cleanup])

    gma.timer(progressbar,1,10,cleanprogress);

    E("Finished");
    E(""); F("");
    E("Testing some textinput stuff...");
    -- string:result            = gma.textinput(string:title,[string:old_text])

    local input_var = "ThisIsAnInput";
    local result = "fake result"; -- = gma.textinput("Test Input", "ThisIsAnInput");
    -- Here is a coroutine necessary
    --[[co = coroutine.create(function ()
        F("Press");
        press_old();
    end)
    coroutine.resume(co);]]
    if(result) then
        F("Input result: '" .. result .. "'");
    else
        errors("gma.textinput");
    end

    E("Finished");
    E(""); F("");
    E("Testing some object stuff...");
    -- number:handle            = gma.show.getobj.handle(string:name)
    -- string:classname         = gma.show.getobj.class(number:handle)
    -- number:index             = gma.show.getobj.index(number:handle)
    -- number:commandline_number= gma.show.getobj.number(number:handle)
    -- string:name              = gma.show.getobj.name(number:handle)
    -- string:label             = gma.show.getobj.label(number:handle)  returns nil if object has no label set
    -- number:amount_children   = gma.show.getobj.amount(number:handle)
    -- number:child_handle      = gma.show.getobj.child(number:handle, number:index)
    -- number:parent_handle     = gma.show.getobj.parent(number:handle)
    -- bool:result              = gma.show.getobj.verify(number:handle)
    -- bool:result              = gma.show.getobj.compare(number:handle1,number:handle2)                    ---Vergleich!

    -- fist we create the sequence
    local seq_name = "test_seq";
    local text = C("delete sequence 1 /nc; store sequence 1 cue 1 thru 3 /nc; label sequence 1 '" .. seq_name .. "'");
    if not text then
        local O=gma.show.getobj;
        local object_name = "sequence 1";
        local handle=O.handle(object_name);
        if(handle) then
            if (O.verify(handle)) then
                F("Attributes of '" .. object_name .. "':");

                local class = O.class(handle);
                if (class and class == "CMD_SEQUENCE") then
                    F("  class  is " .. class);
                else
                    errors("gma.show.getobj.class");
                end

                local index = O.index(handle);
                if (index and index == 0) then
                    F("  index  is " .. index);
                else
                    errors("gma.show.getobj.index");
                end

                local number = O.number(handle);
                if (number and number == "1") then
                    F("  number is " .. number);
                else
                    errors("gma.show.getobj.number");
                end

                local name = O.name(handle);
                if (name and name == seq_name .. " " .. number) then
                    F("  name   is " .. name);
                else
                    errors("gma.show.getobj.name");
                end

                local label = O.label(handle);
                if (label and label == seq_name) then
                    F("  label  is " .. label);
                else
                    errors("gma.show.getobj.label");
                end

                local amount = O.amount(handle);
                if (amount and amount == 4) then
                    F("  amount is " .. amount);
                else
                    errors("gma.show.getobj.amount");
                end
                F("");
            else
                errors("gma.show.getobj.verify");
            end

            local child_index = 1; -- attention, we are NOT requesting cue zero !
            local child_handle = O.child(handle,child_index);
            if(child_handle) then
                F("Found a child of " .. object_name .. ":");
                F("  name   of child no." .. child_index .. " is " .. O.name(child_handle));
                F("  number of child no." .. child_index .. " is " .. O.number(child_handle));
                F("");
            else
                errors("gma.show.getobj.child");
            end

            local parent_handle = O.parent(child_handle);
            if (parent_handle) then
                if (O.compare(handle,parent_handle)) then
                    F("Validated the parent of " .. O.name(child_handle) .. " sucessfully");
                else
                    errors("gma.show.getobj.compare");
                end
            else
                errors("gma.show.getobj.parent");
            end
        else
            errors("gma.show.getobj.handle");
        end

        E("Finished");
        E(""); F("");
        E("Testing some property stuff...");
        -- number:amount            = gma.show.property.amount(number:handle)
        -- string:property_name     = gma.show.property.name(number:handle,number:index)
        -- string:property          = gma.show.property.get(number:handle,number:index/string:property_name)

        local P=gma.show.property;

        if(handle) then
            local amount = P.amount(handle);
            if (amount and amount > 0) then
                F("Found " .. amount+1 .. " properties for '" .. object_name .. "'");
                for i=0,amount-1,1 do
                    local name = P.name(handle,i);
                    if (name and #name > 0) then
                        local property = P.get(handle,i);
                        if(property) then
                            F("Property " .. i+1 .. ". " ..  name .. " from '" .. object_name .. "' is: " .. property);
                        else
                            errors("gma.show.property.get: (Loopcount:" .. i .. ", Name: " .. name .. ")");
                        end
                    else
                        errors("gma.show.property.name: (Loopcount:" .. i .. ")");
                    end
                end
            else
                errors("gma.show.property.amount");
            end
        end
    else
        errors("CMD-Error: " .. text);
    end

    E("Finished");
    E(""); F("");
    E("Testing some show environment variables stuff...");
    -- string:value             = gma.show.getvar(string:varname)
    -- bool:success             = gma.show.setvar(string:varname,string:value)

    local result = gma.show.getvar("SHOWFILE");
    if (result and #result > 0) then
        F("You have loaded show: " .. result);
    else
        errors("gma.show.getvar");
    end

    local value = "THISISLUA!";
    local varname = "TESTVAR";
    result = gma.show.setvar(varname,value);
    if (result) then
        if (value == gma.show.getvar("TESTVAR")) then
            F("Settet global '" .. varname .. "' to " .. value);
        else
            errors("gma.show.setvar");
        end
    end

    E("Finished");
    E(""); F("");
    E("Testing some user environment variables stuff...");
    -- string:value             = gma.user.getvar(string:varname)
    --                            gma.user.setvar(string:varname,string:value")
    -- number:object handle     = gma.user.getcmddest()
    -- number:object_handle     = gma.user.getselectedexec()

    local value = "THISISJUSTFORMYUSER";
    local varname = "TESTVAR";
    gma.user.setvar(varname,value);
    if (value == gma.user.getvar(varname)) then
        F("Selected your value to " .. value);
    else
        errors("gma.user.getvar / gma.user.setvar");
    end

    text = C("cd /; cd plugins");
    if not (text) then
        local object handle = gma.user.getcmddest();
        if (object_handle) then
            F("CMD-Dest-Handle: " .. object_handle);
        else
            errors("gma.user.getcmddest");
        end
    else
        errors("CMD-Error: " .. text);
    end
    C("cd /");
    C("Store Executor 1 /o; Select Executor 1");
    object_handle = gma.user.getselectedexec();
    if (object_handle) then
        local exec_num = string.sub(gma.show.getvar("SELECTEDEXEC"),5);
        --F("executor " .. exec_num);
        --F("Handle_1: " .. object_handle);
        --F("Handle_2: " .. tostring(gma.show.getobj.handle("Executor " .. exec_num)));
        if (object_handle > 0 and  object_handle == gma.show.getobj.handle("executor " .. exec_num)) then
            F("Selected Exec-Handle: " .. object_handle .. " is executor " .. gma.show.getobj.name(object_handle));
        else
            if(object_handle <= 0) then
                errors("gma.user.getselectedexec: (Invalid Handle)");
            else
                errors("gma.user.getselectedexec: (2nd Level Check)");
            end
        end
    else
        errors("gma.user.getselectedexec");
    end

    E("Finished");
    E(""); F("");
    E("Testing network stuff...");
    F("Network Information:");
    -- string:type              = gma.network.gethosttype()
    -- string:subtype           = gma.network.gethostsubtype()
    -- string:ip                = gma.network.getprimaryip()
    -- string:ip                = gma.network.getsecondaryip()
    -- string:status            = gma.network.getstatus()
    -- number:session_number    = gma.network.getsessionnumber()
    -- string:session_name      = gma.network.getsessionname()
    -- number:slot              = gma.network.getslot()

    result = gma.network.gethosttype();
    if(result and #result > 0 and result == gma.show.getvar("HOSTTYPE")) then
        F("Hosttype: " .. result);
    else
        errors("gma.network.gethosttype");
    end

    result = gma.network.gethostsubtype();
    if(result and #result > 0 and result == gma.show.getvar("HOSTSUBTYPE")) then
        F("Hostsubtype: " .. result);
    else
        errors("gma.network.gethostsubtype");
    end

    result = gma.network.getprimaryip();
    if(result and #result > 0 and result == gma.show.getvar("HOSTIP")) then
        F("PrimaryIP: " .. result);
    else
        errors("gma.network.getprimaryip");
    end

    result = gma.network.getsecondaryip();
    if(result and #result > 0) then
        F("SecondaryIP: " .. result);
    else
        errors("gma.network.getsecondaryip");
    end

    result = gma.network.getstatus();
    if(result and #result > 0) then
        F("Hoststatus: " .. result);
    else
        errors("gma.network.getstatus");
    end

    result = gma.network.getsessionnumber();
    if(result and result >= 0) then
        F("Session-No.: " .. result);
    else
        errors("gma.network.getsessionnumber");
    end

    result = gma.network.getsessionname();
    if(result and #result > 0) then
        F("Session-Name: " .. result);
    else
        errors("gma.network.getsessionname");
    end

    result = gma.network.getslot();
    if(result and result >= 0) then
        F("Slot: " .. result);
    else
        errors("gma.network.getslot");
    end

    E("Finished");
    E(""); F("");
    E("Testing some more network stuff...");
    -- table:host_data          = gma.network.gethostdata(string:ip,[table:recycle])
    -- table:slot_data          = gma.network.getmanetslot(number:slot,[table:recycle])
    -- table:performance_data   = gma.network.getperformance(number:slot,[table:recycle])

    local hostDataTable;
    hostDataTable = gma.network.gethostdata(nil);
    if(hostDataTable["version"]) then
        for k in pairs(hostDataTable) do
            F("Var " .. k .. ": " .. tostring(hostDataTable[k]));
        end
    else
        errors("gma.network.gethostdata");
    end

    E("Finished");
    F("");
    F("********************** Summary **********************");
    if (#var_errors > 0) then
        F("We have some (" .. #var_errors .. ") problems:");
        for i = 1, #var_errors do
            F(var_errors[i]);
        end
    else
        F("We have no recognized errors");
        F("This API runs like cream");
    end
    E("");
    E("********************** End of LUA API Test **********************");

end

function printInfo(command,text)
    for i = 1, #command do
        result = command[i];
        if(result) then
            F(text[i] .. ": " .. result);
        else
            errors(command);
        end
    end
end

local handle = nil;

function progressbar(time_int,n)
    -- number:handle            = gma.gui.progress.start(string:progress_name)
    --                            gma.gui.progress.stop(number:progress_handle)
    --                            gma.gui.progress.settext(number:progress_handle,string:text)
    --                            gma.gui.progress.setrange(number:progress_handle,number:from,number:to)
    --                            gma.gui.progress.set(number:progress_handle,number:value)
    if (n == 0) then
        handle = gma.gui.progress.start("Testprogress");
        if not (handle) then
            errors("gma.gui.progress.start");
        else
            gma.gui.progress.setrange(handle,1,10);
        end
    elseif(n == 10) then
        gma.gui.progress.stop(handle);
        handle = nil;
    else
        if (handle) then
            gma.gui.progress.set(handle,n);
            if (n == 6) then
                gma.gui.progress.settext(handle,"Testprogress - comes to the end")
            end
        end
    end
end

function cleanprogress()
    gma.gui.progress.stop(handle);
    handle = nil;
end

function errors(text)
    E("An error occured!");
    var_errors[#var_errors+1] = "Error: " .. tostring(text) .. " failed.";
end

function press()
    gma.feedback("pressing please");
    if not(gma.canbus.hardkey(106,true,false)) then -- Pressing virtual please
        gma.feedback("pressing esc");
        if not gma.canbus.hardkey(54,true,false) then -- Pressing virtual esc
            E("Failded to press any key!");
            errors("gma.canbus.hardkey");
        end
    end
end

function press_old()
    gma.feedback("pressing esc");
    if not(gma.canbus.hardkey(54,true,false)) then -- Pressing virtual esc
        gma.feedback("pressing please");
        if not gma.canbus.hardkey(106,true,false) then -- Pressing virtual please
            E("Failded to press any key!");
            errors("gma.canbus.hardkey");
        end
    end
end

return API_Test;