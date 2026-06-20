--*******************************************************************************************
-- This script tests the methods to 'park' a presettype. 
-- DMXSnapshot 345+346
--*******************************************************************************************

local test =
{
    method_name      = "PARK";
    object_name      = "PRESETTYPE";
    pre              = 'ClearAll; delete dmxsnap 345 /nc';
    steps =
    {
        {
            -- park presettype position
            pre  = 'fixture thru; presettype position at 42';
            cmd  = 'park presettype position; clearall; fixture thru; presettype position at 100;';
            post = 'label dmxsnap 345 "PAR_PRT_1"';
            cleanup = 'unpark thru';
            test_dmx = true;
            test = 345;
            gold = 346;
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