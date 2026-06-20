--*******************************************************************************************
-- This Plugin tests the import fuction for a feature.
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "IMPORT";
    object_name      = "FEATURE";
    pre              = 'ClearAll';

    steps =
    {
        {
            smoketest = true;
            pre = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 80; cd editsetup; cd presettypes; cd color ';
            cmd  = 'Import "import-feature-colorrgb.xml"'; --at feature 1
            post = 'off page thru';
            cleanup = '';
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