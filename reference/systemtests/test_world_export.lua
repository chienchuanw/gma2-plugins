--*******************************************************************************************
-- This Plugin tests the export fuction for groups. 
-- World 100,101
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "EXPORT";
    object_name      = "WORLD";
    pre              = 'ClearAll; world 1; delete world 100 /nc';
 
    steps =
    {
        {
            smoketest =true;
            pre  = 'Fixture 1 thru ' .. math.floor(fixturecount[2]/3) .. ' + ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+math.floor(fixturecount[2]/4) .. '; store world 100 /nc';
            cmd  = 'Export world 100 "export-world.xml" /nc';
            post = 'label world 100 "EXP_WOR_1"';
            cleanup	 = 'world 1';
        },
        {
            cmd  = 'Import "export-world.xml" at world 101  /nc';
            post = 'label world 101 "EXP_WOR_2"';
            cleanup	 = 'world 1';
            --test = 101;
            --gold = 102;
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