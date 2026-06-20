--*******************************************************************************************
-- This script tests the select operation for layouts. 
-- Layout 34
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "SELECT";
    object_name      = "LAYOUT";
    pre              = 'ClearAll; delete layout 34 /nc;';
    steps =
    {
        {
            smoketest= true;
            pre  = 'Fixture 1 thru ' .. math.floor(fixturecount[2]/2) ..'; store layout 34; clearall';
            cmd  = 'select layout 34';   
            post = 'label layout 34 "SEL_LAY_1"';
            cleanup = '';
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