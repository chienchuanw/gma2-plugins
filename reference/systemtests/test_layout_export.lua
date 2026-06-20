--*******************************************************************************************
-- This script tests the operation export for layouts. 
-- Layout 201
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "EXPORT";
    object_name      = "LAYOUT";
    pre              = 'ClearAll; delete layout 201 /nc';
    steps =
    {
        {
            smoketest =true;
            pre  = 'fixture 1 thru '..math.floor(fixturecount[2]/3)..' at 50; store layout 201';
            cmd  = 'export layout 201 "export_layout.xml" /nc';
            post = 'label layout 201 "EXP_LAY_1"';
            cleanup = '';
            --test = 201;
            --gold = 202;
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