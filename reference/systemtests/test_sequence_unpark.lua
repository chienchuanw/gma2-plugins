--*******************************************************************************************
-- This script tests the method to unpark a sequence. 
-- Seq 36, DmxSnap 457
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UNPARK";
    object_name      = "SEQUENCE";
    pre              = 'ClearAll; delete sequence 36 /nc; delete DmxSnapshot 457 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2]+fixturecount[3] .. ' at 100; store sequence 36 cue 1; park sequence 36';
            cmd  = 'unpark sequence 36; ; Fixture 1 thru ' .. fixturecount[2]+fixturecount[3] .. ' at 10; store sequence 36 cue 2; clearall; go sequence 36';
            post = 'label DmxSnapshot 457 "UNP_SEQ_1"; label sequence 36 "UNP_SEQ_1"';
            cleanup = '';
            test_dmx = true;
            test = 457;
            gold = 957;
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