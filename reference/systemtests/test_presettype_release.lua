--*******************************************************************************************
-- This script tests the methods to 'release' a presettype. 
-- DMXSnapshot 392, Seq 196
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "RELEASE";
    object_name      = "PRESETTYPE";
    pre              = 'ClearAll; delete dmxsnap 392 /nc; delete seq 196 /nc';
    steps =
    {
        {
            -- release presettype position
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2] + fixturecount[3] .. '; presettype dimmer full; presettype position full; store seq 196 cue 1 /nc';
            cmd  = 'edit seq 196 cue 1 /nc; release presettype position; update /nc; clearall; go seq 196';
            post = 'label seq 196 "REL_PRT_1"; label dmxsnap 392 "REL_PRT_1"';
            cleanup = '';
            test_dmx = true;
            test = 392;
            gold = 393;
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