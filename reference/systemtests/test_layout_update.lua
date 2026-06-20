--*******************************************************************************************
-- This script tests the methods to update a layout. 
-- Layout 27
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UPDATE";
    object_name      = "LAYOUT";
    pre              = 'ClearAll; delete Layout 27 /nc';
    steps =
    {
        {
            pre  = 'Channel 1 thru; store Layout 27 /nc; Fixture 1 thru ';
            cmd  = 'update Layout 27 /nc';
            post = 'label Layout 27 "UPD_LAY_1"';
            cleanup = '';
            test = 27;
            gold = 127;
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