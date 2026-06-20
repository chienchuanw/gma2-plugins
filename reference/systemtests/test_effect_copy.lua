--*******************************************************************************************
-- This script tests the methods to copy a effect 
-- Effect 33-36
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "COPY";
    object_name      = "EFFECT";
    pre              = 'ClearAll; delete effect 33 thru 36 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Position"; at Form "swing"; at effectBPM 20; store Effect 33';
            cmd  = 'Copy Effect 33 at 34 /nc';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 33 "COPY_EFF_1"; label effect 34 "COPY_EFF_2"';
            cleanup = 'off effect thru;  clearall';
            test = 34;
            gold = 234;
        },
        {
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; Presettype "Dimmer"; at form "PWM"; at effectBPM 100; store Effect 35; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; Presettype "Dimmer"; at form "PWM"; at effectBPM 10; store Effect 36';
            cmd  = 'Copy Effect 35 at 36 /merge';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 35 "COPY_EFF_3"; label effect 36 "COPY_EFF_4"';
            cleanup = 'off effect thru';
            test = 36;
            gold = 236;
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