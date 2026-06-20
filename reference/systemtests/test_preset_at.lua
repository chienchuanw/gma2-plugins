--*******************************************************************************************
-- This Plugin tests the at fuction for presets. 
-- Preset 1.3-1.5, World 46
--*******************************************************************************************

local test =
{
    method_name         = "AT";
    object_name         = "PRESET";
    pre                 = 'ClearAll; delete Preset 1.3 thru 1.5 /nc; delete world 46 /nc';
    steps =
    {
        { 
            pre         = 'Fixture 1 at 92 ; store preset 1.3 /nc';
            cmd         = 'at Preset 1.3; store Preset 1.4';
            post        = 'label Preset 1.3 "PRES_AT_1"; label Preset 1.4 "PRES_AT_2"';
            cleanup     = 'off page thru; clearall';
            test        = 1.4;
            gold        = 1.104;
        },
        {
            pre         = 'Fixture 1 thru 5 ; store world 46 /nc; label world 46 "PRES_AT_1"; world 1; fixture 1 thru 10 at 90; store preset 1.5; world 46';
            cmd         = 'at Preset 1.5; store Preset 1.5';
            post        = 'label Preset 1.5 "PRES_AT_3"; label Preset 1.5 "PRES_AT_4"';
            cleanup     = 'world 1';
            test        = 1.5;
            gold        = 1.105;
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