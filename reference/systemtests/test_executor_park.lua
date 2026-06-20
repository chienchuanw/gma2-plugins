--*******************************************************************************************
-- This script tests the method park to an executor. 
-- Exec 48, Sequ 145, DmxSnap 143
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "PARK";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete executor 48 /nc; delete sequence 145 /nc; delete DmxSnapshot 143 /nc';
    steps=
    {
        {
            pre  = 'Fixture 1 thru '..fixturecount[2] .. ' at 80; store sequence 145 cue 1; assign sequence 145 at executor 48';
            cmd  = 'park executor 48; Fixture 1 thru '..fixturecount[2] .. ' at 50';
            post = 'label executor 48 "PARK_EXEC_1"; label sequence 145 "PARK_EXEC_1"; label DmxSnapshot 143 "PAR_EXEC_1"';
            cleanup = '';
            test_dmx = true;
            test = 143;
            gold = 643;
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