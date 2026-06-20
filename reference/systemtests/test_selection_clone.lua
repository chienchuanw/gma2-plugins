--*******************************************************************************************
-- This script tests the method to clone a selection. 
-- Pres 1.60
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "CLONE";
    object_name      = "SELECTION";
    pre              = 'CLearAll; delete preset 1.60 /nc';
    steps =
    {
        {
            pre  = 'fixture ' .. fixturecount[2] .. ' at 25; store preset 1.60 /overwrite; ClearAll; fixture ' .. fixturecount[2]+2 .. ' thru ' .. fixturecount[2]+math.floor(fixturecount[2]/2);
            cmd  = 'clone fixture ' .. fixturecount[2]+2 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at ' .. fixturecount[2]+1 .. ' if selection and preset 1.60 /lowmerge /nc';
            post = 'label preset 1.60 "CLNE_SEL_1"';
            cleanup = '';
            test = '1.60';  --comparison  of presets   -- Achtung bei null am ende nach dem punkt muss es ein string sein
            gold = '1.160';
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