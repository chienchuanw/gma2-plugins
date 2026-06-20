--*******************************************************************************************
-- This script tests the method to park a sequence. 
-- Seq 30, DmxSnap 455
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "PARK";
    object_name      = "SEQUENCE";
    pre              = 'ClearAll; delete sequence 30 /nc; delete DmxSnapshot 455 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2]+fixturecount[3] .. ' at 100; store sequence 30 cue 1';
            cmd  = 'park sequence 30; Fixture 1 thru ' .. fixturecount[2]+fixturecount[3] .. ' at 50';
            post = 'label DmxSnapshot 455 "PARK_SEQ_1"; label sequence 30 "PARK_SEQ_1"';
            cleanup = '';
            test_dmx = true;
            test = 455;
            gold = 955;
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