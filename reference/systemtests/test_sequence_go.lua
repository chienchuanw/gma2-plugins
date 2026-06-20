--*******************************************************************************************
-- This script tests the go function to a sequence. 
-- Seq 15, DmxSnap 451
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name         = "GO";
    object_name         = "SEQUENCE";
    pre                 = 'ClearAll; delete sequence 15 /nc; delete DmxSnapshot 451 /nc';
    version_script      = '3.2.53.0';
   
    steps =
    {
        {
            pre         = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 80; attribute "Tilt" at 44 thru 136; store sequence 15 cue 1 /nc; clearall';
            cmd         = 'go sequence 15';
            post        = 'label sequence 15 "SEQ_GO"; label DmxSnapshot 451 "SEQ_GO_1"';
            cleanup = '';
            test_dmx    = true;
            test        = 451;
            gold        = 951;
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