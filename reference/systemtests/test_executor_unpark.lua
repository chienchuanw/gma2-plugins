--*******************************************************************************************
-- This script tests the method unpark to an executor. 
-- Exec 64, Sequ 160, DmxSnap 161
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UNPARK";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete executor 64 /nc; delete sequence 160 /nc; delete DmxSnapshot 161 /nc';
    steps=
    {
        {
            pre  = 'Fixture 1 thru '..fixturecount[2]..' at 80; store sequence 160 cue 1; assign sequence 160 at executor 64; park executor 64; clearall';
            cmd  = 'unpark executor 64; Fixture 1 thru '..fixturecount[2]..' at 25';
            post = 'label executor 64 "UNP_EXEC_1"; label sequence 160 "UNP_EXEC_1"; label DmxSnapshot 161 "UNP_EXEC_1"';
            cleanup = '';
            test_dmx = true;
            test = 161;
            gold = 661;
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