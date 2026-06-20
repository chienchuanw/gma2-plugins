--*******************************************************************************************
-- This script shows up the methods to delete a world. 
-- World 8+9
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "DELETE";
    object_name      = "WORLD";
    pre              = 'ClearAll; world 1; delete world 8 + 9 /nc';
    exit_cmd	     = 'world 1';

    steps=
    {
        {
            pre  = 'fixture 1 thru ' ..math.floor(fixturecount[2]/3).. '; store world 8 /nc';
            cmd  = 'delete world 8';
            post = 'label world 8 "WOR_DEL_1"';
            cleanup= 'clearall; off page thru; world 1';
            test = 8;   
            gold = -1;
        },
        {
            pre  = 'fixture 1 thru ' ..math.floor(fixturecount[2]/3).. '; store world 9; label world 9 "WOR_DEL_2"';
            cmd  = 'delete world "WOR_DEL_2"';
            cleanup	 = 'world 1';
            test = 9;
            gold = -1;
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