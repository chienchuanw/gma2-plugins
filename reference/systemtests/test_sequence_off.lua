--*******************************************************************************************
-- This script tests the methods to off a sequence 
-- Seq 29, DmxSnap 454
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "OFF";
    object_name      = "SEQUENCE";
    pre              = 'ClearAll; delete sequence 29 /nc; delete DmxSnapshot 454 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. ' at 25; store sequence 29 cue 1; clearall; go sequence 29; clearall';
            cmd  = 'off sequence 29';
            post = 'label sequence 29 "OFF_SEQ_1"; label DmxSnapshot 454 "OFF_SEQ_1"';
            cleanup = '';
            test_dmx = true;
            test = 454;
            gold = 954;
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