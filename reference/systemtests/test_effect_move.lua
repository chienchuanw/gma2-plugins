--*******************************************************************************************
-- This script tests the move operation in a effect pool. 
-- Effect 42
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "MOVE";
    object_name      = "EFFECT";
    pre              = 'ClearAll; delete effect 42 /nc' ;
    steps =
    {
        {
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; Presettype "Position"; at Form "swing"; at effectBPM 20; store Effect 42 /nc';
            cmd  = 'move effect 42 at 43 /nc';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 43 "MOVE_EFF_1"';
            cleanup = 'off effect thru';
            test = 43;
            gold = 243;
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