--*******************************************************************************************
-- This script tests the methods to 'remove' a presettype. 
-- DMXSnapshot 394, Seq 197
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "REMOVE";
    object_name      = "PRESETTYPE";
    pre              = 'ClearAll; delete dmxsnap 394 /nc; delete seq 197 /nc';
    steps =
    {
        {
            -- remove presettype position in cue 2
            pre  = 'fixture thru; presettype dimmer at 65; store seq 197 /nc; clearall; fixture thru; presettype dimmer full; store seq 197 /a';
            cmd  = 'edit seq 197 cue 2 /nc; release presettype dimmer; update /nc; clearall; go seq 197; go seq 197';
            post = 'label seq 197 "REM_PRT_1"; label dmxsnap 394 "REM_PRT_1"';
            cleanup = '';
            test_dmx = true;
            test = 394;
            gold = 395;
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