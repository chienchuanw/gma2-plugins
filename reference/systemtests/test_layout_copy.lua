--*******************************************************************************************
-- This script tests the methods to copy a layout 
-- Layout 3 - 5
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "COPY";
    object_name      = "LAYOUT";
    pre              = 'ClearAll; delete layout 3 thru 5 /nc';
    steps =
    {
        {
            pre  = 'channel thru; store layout 3 /nc';
            cmd  = 'copy layout 3 at 4 /nc';
            post = 'label layout 3 "CPY_LAY_1"; label layout 4 "CPY_LAY_2"';
            cleanup = 'clearall; off page thru; off sequence thru';
            test = {3,4};
            gold = {103,104};
        },
        {
            cmd  = 'copy layout "CPY_LAY_2" at 5 /nc';
            post = 'label layout 5 "CPY_LAY_3"';
            cleanup = '';
            test = 5;
            gold = 105;
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