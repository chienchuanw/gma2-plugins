--*******************************************************************************************
-- This script tests the operation import for layouts. 
-- Layout 203
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "IMPORT";
    object_name      = "LAYOUT";
    pre              = 'ClearAll; delete layout 203 /nc';
    steps =
    {
        {
            smoketest = true;
            pre  = '';
            cmd  = 'import "import-layout.xml" at layout 203 /nc';
            post = 'label layout 203 "IMP_LAY_1"';
            cleanup = '';
            --test = 203;
            --gold = 204;
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