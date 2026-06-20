--*******************************************************************************************
-- This script tests the methods to assign an effect 
-- Effect 29
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ASSIGN";
    object_name      = "EFFECT";
    pre              = 'ClearAll; delete effect 29 /nc';
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Dimmer"; at form "Ramp"; store Effect 29 /nc';
            cmd  = 'ClearAll; Assign Effect 1.29.1 /lowvalue = 5 /speed = 80 /width = 90';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 29 "ASS_EFF_1"';
            cleanup = 'off effect thru';
            test = 29;
            gold = 229;
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