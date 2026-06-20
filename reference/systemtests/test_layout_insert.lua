--*******************************************************************************************
-- This script tests the operation insert for layouts. 
-- Layout 23,24
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "INSERT";
    object_name      = "LAYOUT";
    pre              = 'ClearAll; delete layout 23 + 24 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' ..math.floor(fixturecount[2]/3).. '; store layout 23; fixture 1 thru ' ..fixturecount[2].. '; store layout 24';
            cmd  = 'insert layout 24 at layout 23 /merge';
            post = 'label layout 23 "INS_LAY_1"; label layout 24 "INS_LAY_2"';
            cleanup = '';
            test = {23,24};
            gold = {123,124};
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