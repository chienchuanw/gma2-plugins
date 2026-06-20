--*******************************************************************************************
-- This script tests the move operation in a preset pool.
-- Move operation is only pool internal possible! Maybe later (STEP 3)
-- Preset 0.9 + 1.22+1.23 + 2.2 - 2.5
-- Label unterschiede sind absicht!
--*******************************************************************************************

local test =
{
    method_name      = "MOVE";
    object_name      = "PRESET";
    pre              = 'ClearAll; delete Preset 0.9 + 1.22 + 1.23 + 2.2 thru 2.5 /nc';
    steps =
    {
        {  
            pre  = 'on fixture 21; fixture 21 at 50; attribute "colorrgb1" at 0; attribute "colorrgb2" at 0; attribute "colorrgb3" at 100; store Preset 1.22 + 2.2 + 2.3 /nc';
            cmd  = 'Move Preset 1.22 at 1.23 /nc';
            post = 'label Preset 1.23 "MOV_PRE_1"; label Preset 2.2 "MOV_PRE_2"; label Preset 2.3 "MOV_PRE_3"';
            cleanup = '';
            test = 1.23;
            gold = 1.123;
        },
        {
            cmd  = 'Move Preset 2.2 thru 2.3 at 2.4 /nc';
            post = 'label Preset 2.4 "MOV_PRES_4"';
            cleanup = '';
            test = 2.4;
            gold = 2.104;
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