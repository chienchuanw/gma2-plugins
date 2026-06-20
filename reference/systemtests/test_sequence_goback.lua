--*******************************************************************************************
-- This script tests the goback function to a sequence. 
-- Seq 16, DmxSnap 452
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name         = "GOBACK";
    object_name         = "SEQUENCE";
    pre                 = 'ClearAll; delete sequence 16 /nc; delete DmxSnapshot 452 /nc';
    version_script      = '3.2.53.0';
   
    steps =
    {
        {
            pre         = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 12 thru 82; store sequence 16 cue 1; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; attribute "Tilt" at 44 thru 90; store sequence 16 cue 2; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; attribute "Tilt" at 1 thru 45; store sequence 16 cue 3 /nc; clearall ';
            cmd         = 'go sequence 16; go sequence 16; GoBack sequence 16';  --doing cue 2
            post 		 = 'label sequence 16 "SEQ_GOBACK_1"; label DmxSnapshot 452 "SEQ_GOBACK_1"';
            cleanup = '';
            test_dmx    = true;
            test        = 452;
            gold        = 952;
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