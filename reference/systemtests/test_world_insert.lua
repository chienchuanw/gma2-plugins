--*******************************************************************************************
-- This script tests the method insert to a world.
-- World 19 - 23
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "INSERT";
    object_name      = "WORLD";
    pre              = 'ClearAll; delete world 19 thru 23 /nc';
    exit_cmd         = 'world 1';
    steps =
    {
        {  --inserting a world at an avialable position
            pre  = 'fixture 1 thru ' .. math.floor(fixturecount[2]/3) ..'; store world 19 /nc; clearall';
            cmd  = 'Insert world 19 at 20 /nc';     --position 19 is now empty
            post = 'label world 20 "INS_WOR_1"';
            cleanup = 'world 1';
            test = 20; 
            gold = 120;
        },
        {
            --inserting a world at an occupied position
            pre  = 'fixture ' .. math.floor(fixturecount[2]/3) + 1 ..' thru ' .. 2*math.floor(fixturecount[2]/3) ..'; store world 21 /nc; clearall; world 1; fixture ' .. 2*math.floor(fixturecount[2]/3)+1 ..' thru ' .. math.floor(fixturecount[2]) ..'; store world 22 /nc; clearall';
            cmd  = 'Insert world 21 at 22 /nc';   --position 21 is now empty, world 22 has moved to world 23
            post = 'label world 22 "INS_WOR_2"; label world 23 "INS_WOR_2"';
            cleanup= 'world 1';
            test = {22,23}; 
            gold = {122,123};
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