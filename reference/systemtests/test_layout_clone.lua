--*******************************************************************************************
-- This script tests the method to clone a layout. 
-- Layout 1
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "CLONE";
    object_name      = "LAYOUT";
    pre              = 'CLearAll; delete layout 1 /nc';
    steps =
    {
        {
            pre  = 'fixture ' .. fixturecount[2]+1 .. '; store layout 1 /nc; ClearAll';
            cmd  = 'clone fixture ' .. fixturecount[2]+2 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at ' .. fixturecount[2]+1 .. ' if layout 1 /lowmerge /nc';
            post = 'label layout 1 "CLNE_LAY_1"';
            cleanup = '';
            test = 1;
            gold = 101;
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