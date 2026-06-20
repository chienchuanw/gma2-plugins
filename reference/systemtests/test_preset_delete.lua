--*******************************************************************************************
-- This script tests the methods to delete a preset. 
-- Preset 0.2 + 1.16
-- presettype.feature.attribute
-- 0 All
-- 1 Dimmer
-- 2 Position
-- 3 Gobo
-- 4 Color
-- 5 Beam
--*******************************************************************************************

local test =
{
    method_name      = "DELETE";
    object_name      = "PRESET";
    pre              = 'ClearAll; delete Preset 1.16 + 0.2 /nc;';
    steps =
    {
        {
            pre  = 'fixture 1 thru 10 at 100; store Preset 1.16 /ka /s /o';
            cmd  = 'Delete Preset 1.16 /nc';
            test = 1.16;
            gold = -1;
        },
        {
            pre  = 'ClearAll; on fixture 1 thru 10; store Preset 0.2 /ka /g /o; clearall';
            cmd  = 'Delete Preset 0.2  /nc';
            post = 'label Preset 0.2 "PRES_DEL_1"';
            cleanup = '';
            test = 0.2;
            gold = -1;
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