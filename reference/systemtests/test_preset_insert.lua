--*******************************************************************************************
-- This script tests the method insert to a preset 
-- Preset 0.3,0.4
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "INSERT";
    object_name      = "PRESET";
    pre              = 'ClearAll; delete preset 0.3 + 0.4 /nc';
    steps =
    {
        {
            pre  = 'Channel 1 thru ' .. fixturecount[1] .. ' at 30; store preset 0.3 /nc; fixture 1 thru ' .. fixturecount[2] .. ' at 40; store preset 0.4 /nc';
            cmd  = 'Insert preset 0.4 at 0.3';
            post = 'label preset 0.3 "INS_PRES_1"; label preset 0.4 "INS_PRES_2"';
            cleanup = '';
            test = {0.3,0.4};
            gold = {0.103,0.104};
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