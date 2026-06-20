--*******************************************************************************************
-- This script shows up the methods to edit a world. 
-- World 17
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "EDIT";
    object_name      = "WORLD";
    pre              = 'ClearAll; world 1; delete world 17 /nc';
    exit_cmd	     = 'world 1';
    steps =
    {
        {
            pre  = 'fixture 1 thru '..math.floor(fixturecount[2]/3)..'; store world 17 /nc; clearall; world 17';
            cmd  = 'Edit world 17; fixture 1 thru '..math.floor(fixturecount[2]/3)..' at 95; off fixture 1 thru ' .. math.floor(fixturecount[1]/4) .. '; update world 17 /nc; world 1; world 17';
            post= 'label world 17 "WOR_EDT"';
            cleanup	 = 'world 1';
            test = 17;   --comparison of worlds
            gold = 117;
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