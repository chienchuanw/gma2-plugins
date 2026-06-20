--*******************************************************************************************
-- This script tests the methods to learn an executor.
-- Comparing for timinig stuff is not possible.
-- Exec 39, Effect 101
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "LEARN";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete executor 39 /nc; delete effect 101 /nc';
    version_step     = '3.3.0.0';
    steps =
    {
        {
            smoketest=true;
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Dimmer"; at form "Ramp"; at effectBPM 0; store Effect 101; assign effect 101 /phase="0..180"; assign effect 101 at executor 39';
            cmd_func  = function() local i = 0; for i=0,4 do gma.cmd('Learn executor 39'); gma.sleep(1); end end;   --simulates the users triggering
            post = 'label effect 101 "LER_EFF_1"; label executor 39 "LER_EFF_1"';
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