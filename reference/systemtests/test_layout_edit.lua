--*******************************************************************************************
-- This script tests the edit operation for layouts. 
-- Layout 10
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "EDIT";
    object_name      = "LAYOUT";
    pre              = 'ClearAll; delete layout 10 /nc';
    steps =
    {
        {  pre  = 'Fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. '; store layout 10';
            cmd  = 'edit layout 10; Fixture 1 thru ' .. fixturecount[2] .. '; update layout 10 /nc';
            post ='label layout 10 "EDIT_LAY_1"';
            cleanup = '';
            test = 10;
            gold = 110;
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