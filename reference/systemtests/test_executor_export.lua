--*******************************************************************************************
-- This script tests the possibilities of the export command to Executors 
-- Exec 131, 132  Group 72
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "EXPORT";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete group 72 /nc; page 1; delete executor 131 + 132 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru '..math.floor((1*fixturecount[2])/12)..'; store group 72 /nc; Assign group 72 at exec 131; assign exec 131 /mode="additive"';
            cmd  = 'export executor 131 "export-executor.xml" /nc';
            post = 'label executor 131 "EXP_EXEC_1"';
            cleanup = 'tozero exec 131';
        },
        {
            pre  = '';
            cmd  = 'import "export-executor.xml" at executor 132; tofull exec 132';
            post = 'label executor 132 "EXP_EXEC_2"';
            cleanup = 'tozero exec 131';
            test_dmx = true;
            test = 236;
            gold = 237;
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