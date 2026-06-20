--*******************************************************************************************
-- This script tests the methods to at a selection to an effect 
-- Effect 30,31
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "AT";
    object_name      = "EFFECT";
    pre              = 'ClearAll; delete effect 30 + 31 /nc';
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Dimmer"; at form "Ramp"; store Effect 30';
            cmd  = 'Fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. ' at Effect 30; store effect 31 /nc';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 30 "AT_EFF_1"; label effect 31 "AT_EFF_2"';
            cleanup = 'off effect thru';
            test = 31;
            gold = 231;
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