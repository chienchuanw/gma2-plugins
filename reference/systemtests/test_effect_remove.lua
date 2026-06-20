--*******************************************************************************************
-- This script tests the methods to remove a effect 
-- Effect 49, Seq 91
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name = "REMOVE";
    object_name = "EFFECT";
    pre         = 'ClearAll; delete effect 49 /nc; delete sequence 91 /nc;';
    steps =
    {
        {
            pre  = ' Fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Color" at 25; store sequence 91 /nc go sequence 91; ClearAll; Fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Color"; at form "Ramp minus"; at effectBPM 2; store Effect 49 /nc; go effect 49';
            cmd  = 'remove effect 49';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 49 "REM_EFF_1"; label sequence 91 "REM_EFF"';
            cleanup = 'off effect thru';
            test = 49;
            gold = 249;
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