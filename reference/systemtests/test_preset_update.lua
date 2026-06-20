--*******************************************************************************************
-- This script tests the methods to update a preset. 
-- Preset 1.26
--*******************************************************************************************

local test =
{
    method_name      = "UPDATE";
    object_name      = "PRESET";
    pre              = 'ClearAll; delete Preset 1.26 /nc; ';
    steps =
    {
        { 
            pre  = 'Channel thru; Fixture thru; at 100; store Preset 1.26 /nc; Channel thru; Fixture thru at 50';
            cmd  = 'update Preset 1.26 /nc';
            post = 'label Preset 1.26 "UPD_PRES_1"';
            cleanup = '';
            test = 1.26;
            gold = 1.126;
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