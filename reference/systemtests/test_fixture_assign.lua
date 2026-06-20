--*******************************************************************************************
-- This script tests the method to assign a fixture. -> CF 
-- DmxSnap 242
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ASSIGN";
    object_name      = "FIXTURE";
    pre              = 'ClearAll; channelpage +; delete DmxSnapshot 242 /nc';
   
    steps =
    {
        {
            pre  = 'fixture 1 thru '..fixturecount[2]..'at 67';
            cmd  = 'Assign Fixture 1 thru ' .. fixturecount[2] .. ' at channelfader 30 thru ';
            post = 'label DmxSnapshot 242 "ASS_FIX_1"';
            cleanup = 'Page 1';
            test_dmx = true;
            test = 242;
            gold = 742;
        },
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