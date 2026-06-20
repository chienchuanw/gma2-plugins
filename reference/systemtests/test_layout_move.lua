--*******************************************************************************************
-- This script tests the move operation in a layout pool.
-- Layout 11 - 15
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "MOVE";
    object_name      = "LAYOUT";
    pre              = 'ClearAll; delete layout 11 thru 15 /nc ';
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. '; store layout 11; Fixture ' .. math.floor(fixturecount[2]/2) .. ' thru ' .. fixturecount[2] .. ' ; store layout 12; label layout 11 "MOV_LAY_1";  label layout 12 "MOV_LAY_2"';
            cmd  = 'Move layout 11 at 13 /nc';
            cleanup = '';
            test = 13;
            gold = 113;
        },
        {
            cmd  = 'Move layout "MOV_LAY_*" at 14 /nc';
            cleanup = '';
            test = 14;
            gold = 114;
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