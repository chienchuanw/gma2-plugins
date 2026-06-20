--*******************************************************************************************
-- This script tests the goto function to a cue. 
-- Seq 77, DmxSnap 53
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name         = "GOTO";
    object_name         = "CUE";
    pre                 = 'ClearAll; delete sequence 77 /nc; delete DmxSnapshot 53 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre         = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 12 thru 82; store sequence 77 cue 1 /nc; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; attribute "Tilt" at 44 thru 153; store sequence 77 cue 2 /nc; clearall';
            cmd         = 'goto sequence 77 cue 2';
            post        = 'label sequence 77 "CUE_GOTO_1"; label DmxSnapshot 53 "CUE_GOTO_1"';
            cleanup = '';
            test_dmx    = true;
            test        = 53;
            gold        = 553;
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