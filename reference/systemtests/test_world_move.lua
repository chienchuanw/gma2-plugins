--*******************************************************************************************
-- This script shows up the methods to move a world. 
-- World 24+25+125
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "MOVE";
    object_name      = "WORLD";
    pre              = 'ClearAll; delete world 24 thru 25 /nc';
    exit_cmd	     = 'world 1';
    
    steps =
    {
        {
            --moving a world at an available position
            pre  = 'fixture 1 thru '..math.floor(fixturecount[2]/4)..'; store world 24 /nc; clearall; world 1';
            cmd  = 'move world 24 at 25 /nc';   --position 24 is empty now
            post ='label world 25 "WOR_MOV_1"';
            cleanup	 = 'world 1';
            test = 25;
            gold = 125;
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