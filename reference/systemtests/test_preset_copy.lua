--*******************************************************************************************
-- This script tests the methods to copy a preset. 
-- Preset 1.10-1.15 + 2.1 + 3.1+3.2
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "COPY";
    object_name      = "PRESET";
    pre              = 'ClearAll; delete Preset 1.8 thru 1.15 + 2.1 + 3.1 + 3.2 /nc';
   
    steps =
    {
        {  
            pre  = 'Fixture ' .. fixturecount[2]+1 .. ' at 100; store Preset 1.8 + 2.1 /nc';
            cmd  = 'copy Preset 1.8 at 1.9 /nc';
            post = 'label Preset 1.8 "PRES_CPY_1"; label Preset 1.9 "PRES_CPY_2"';
            cleanup = '';
            test = 1.9;
            gold = 1.109;
        },
        {
            cmd  = 'copy Preset 1.8 at 1.10 thru 1.12 /nc';
            post = 'label Preset 1.10 "PRES_CPY_3"; label Preset 1.11 "PRES_CPY_4"; label Preset 1.12 "PRES_CPY_5"';
            cleanup = '';
            test = {'1.10',1.11,1.12};  -- Achtung bei null am ende nach dem punkt muss es ein string sein
            gold = {'1.110',1.111,1.112};
        },
        {
            pre  = '';
            cmd  = 'copy Preset 2.1 at 1.15 /merge';
            post = 'label Preset 1.15 "PRES_CPY_9"';
            cleanup = '';
            test = 1.15;
            gold = 1.115;
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