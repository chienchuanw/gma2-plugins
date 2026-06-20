--*******************************************************************************************
-- This script tests the method on to a dmx-value. For the GMA DMX Tester Output
-- The dmx tester has highest priority. Make sure to reset!!
-- THIS IS A SMOKETEST!
-- no output generated
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ON";
    object_name      = "DMX";
    pre              = 'ClearAll';
    version_script   = '3.2.55.4';
    --test_type        = 'function';
   
    steps =
    {
        {
            smoketest = true;
            pre = 'DMX 1.1 thru 1.' .. fixturecount[1] .. ' at 0 thru 100';
            cmd  = 'On DMX 1.1';
            --result = function() local h = gma.show.getobj.handle("DMX 1.1"); if(gma.show.property.get(h,7) == "true") then return true end return false end;
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