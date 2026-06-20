--*******************************************************************************************
-- This script tests the goback function to a sequence. 
-- Seq 17, DmxSnap 453
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name         = "GOTO";
    object_name         = "SEQUENCE";
    pre                 = 'ClearAll; delete sequence 17 /nc; delete DmxSnapshot 453 /nc';
    version_script      = '3.2.53.0';
   
    steps =
    {
        {
            pre         = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 12 thru 82; store sequence 17 cue 1 /nc; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; attribute "Tilt" at 44 thru 136; store sequence 17 cue 2 /nc';
            cmd         = 'goto sequence 17 cue 2';
            post        = 'label sequence 17 "SEQ_GOTO_1"; label DmxSnapshot 453 "SEQ_GOTO_1"';
            cleanup = '';
            test_dmx    = true;
            test        = 453;
            gold        = 953;
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