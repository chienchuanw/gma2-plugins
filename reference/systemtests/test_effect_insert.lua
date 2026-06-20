--*******************************************************************************************
-- This script tests the methods to insert an effect 
-- Effect 40-41
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "INSERT";
    object_name      = "EFFECT";
    pre              = 'ClearAll; delete effect 40 thru 41 /nc';
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Dimmer"; at form "Ramp"; at effectBPM 80; store Effect 40 /nc; Fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; Presettype "Position"; at form "Circle"; at effectBPM 0; store Effect 41 /nc';
            cmd  = 'insert Effect 41 at 40 /merge'; --swapping positions
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 40 "INS_EFF_1"; label effect 41 "INS_EFF_2"';
            cleanup = 'off effect thru';
            test = {40,41};
            gold = {240,241};
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