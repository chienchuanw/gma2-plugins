--*******************************************************************************************
-- This script shows up the methods to assign a specialmaster. 
-- Page 101, Exec 101.1, DmxSnapshot 471, 871
--*******************************************************************************************

local test =
{
    method_name      = "ASSIGN";
    object_name      = "SPECIALMASTER";
    pre              = 'ClearAll; delete page 101 /nc; store page 101; page 101;';

    steps =
    {
        {
            -- assign grand master at exec 101.1
            pre  = 'channel thru at 50';
            cmd  = 'assign sm 2.1 at exec 101.1; exec 101.1 at 50';
            post ='label page 101 "ASS_SPE_1"; label exec 101.1 "ASS_SPE_1"; label dmxsnap 471 "ASS_SPE_1"';
            cleanup	 = 'del exec 101.1; sm 2.1 full; page 1';
            test_dmx = true;
            test = 471;
            gold = 871;
        }
    };
};

RegisterTestScript(test);

--*******************************************************************************************
-- module entry point
--*******************************************************************************************

local function StartThisTest()
   StartSingleTestScript(test);
end

return StartThisTest;