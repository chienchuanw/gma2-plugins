--*******************************************************************************************
-- This script tests the method to learn a page.
-- Comparing for timinig stuff is not possible.
-- Page 94, Effect 11
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test=
{
    method_name     = "LEARN";
    object_name     = "PAGE";
    pre             = 'ClearAll; delete page 94 /nc; store page 94; page 94; delete effect 11 /nc';
    steps =
    {
        {
            -- Learn Page 94
            smoketest=true;
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Dimmer"; at form "Ramp"; at effectBPM 0; store Effect 11; assign effect 11 /phase="0..180"; assign effect 11 at exec 94.1';
            cmd_func  = function() local i = 0; for i=0,4 do gma.cmd('Learn page 94'); gma.sleep(0.25); end end;   --simulates the users triggering
            post = 'label effect 11 "LER_PAG_1"; label exec 94.1 "LER_PAG_1"';
            cleanup = '';
        },
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