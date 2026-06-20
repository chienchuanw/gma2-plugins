--*******************************************************************************************
-- This Plugin tests the export fuction for worlds.
-- World 103
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "IMPORT";
    object_name      = "WORLD";
    pre              = 'ClearAll; world 1; delete world 103 /nc';

    steps =
    {
        {
            smoketest = true;
            cmd  = 'Import "import-world.xml" at world 103';
            post = 'label world 103 "IMP_WOR_1"';
            cleanup	 = 'world 1';
            test = 103;
            gold = 104;
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