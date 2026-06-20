--*******************************************************************************************
-- This script shows the methods to call a sequence.
-- Seq 4, DmxSnap 450
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name         = "CALL";
    object_name         = "SEQUENCE";
    pre                 = 'ClearAll; delete sequence 4 /nc; delete DmxSnapshot 450 /nc';
    steps =
    {
        {
            pre         = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. math.floor(fixturecount[2]+(fixturecount[2]/2)) .. ' at 100; store sequence 3 cue 1.5 /nc';
            cmd         = 'Call sequence 3';
            post 		 = 'label sequence 3 "SEQ_CALL_1"; label DMXsnapshot 450 "SEQ_CALL_1"';
            cleanup = '';
            test_dmx    = true;
            test        = 450;
            gold        = 950;
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