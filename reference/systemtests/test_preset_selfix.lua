--*******************************************************************************************
-- This script tests the method select the fixtures of a preset 
-- preset 0.11+0.12
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "SELFIX";
    object_name      = "PRESET";
    pre              = 'delete preset 0.11 + 0.12 /nc';
    steps =
    {
        {  
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 34.5; store preset 0.11 /nc';
            cmd  = 'selfix preset 0.11; at 34.5; store preset 0.12 /nc';
            post = 'label preset 0.11 "SELF_PRES_1"; label preset 0.12 "SELF_PRES_2"';
            cleanup = '';
            test = 0.12;
            gold = 0.112;
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