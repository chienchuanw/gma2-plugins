--*******************************************************************************************
-- This script tests the pause function to a sequence. This works only for virtual playbacks
-- Seq 31, DmxSnap 458
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name         = "PAUSE";
    object_name         = "SEQUENCE";
    pre                 = 'ClearAll; delete sequence 31 /nc; delete DmxSnapshot 456 /nc';
    version_script      = '3.2.53.0';
   
    steps =
    {
        {
            pre         = 'fixture 1  thru ' .. fixturecount[2]+fixturecount[3] .. '; attribute "Tilt" at 44 thru 136; store sequence 31 cue 2; clearall; go sequence 31';
            cmd         = 'pause sequence 31';
            post        = 'label sequence 31 "PAU_SEQ_1"; label DmxSnapshot 456 "PAU_SEQ_1"';
            cleanup = '';
            test_dmx    = true;
            test        = 458;
            gold        = 958;
        }
    }
};

RegisterTestScript(test);

--*******************************************************************************************
-- module entry point
--*******************************************************************************************

local function StartThisTest()
    StartSingleTestScript(test);
end

return StartThisTest;