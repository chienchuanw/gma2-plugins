--*******************************************************************************************
-- This script tests the methods to 'unpark' a presettype. 
-- DMXSnapshot 347+348
--*******************************************************************************************

local test =
{
    method_name      = "UNPARK";
    object_name      = "PRESETTYPE";
    pre              = 'ClearAll; delete dmxsnap 347 /nc';
    steps =
    {
        {
            -- park presettype position
            pre  = 'fixture thru; presettype position at 42; park presettype position';
            cmd  = 'unpark presettype position; presettype position at 100';
            post = 'label dmxsnap 347 "UNP_PRT_1"';
            cleanup = '';
            test_dmx = true;
            test = 347;
            gold = 348;
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