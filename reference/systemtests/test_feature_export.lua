--*******************************************************************************************
-- This Plugin tests the export fuction for a feature.
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "EXPORT";
    object_name      = "FEATURE";
    pre              = 'ClearAll';
    steps =
    {
        {  smoketest = true;
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 80; feature colorrgb at 70';
            cmd  = 'export feature colorrgb "export-feature-colorrgb.xml" /nc'; 
            post = 'clearall; off page thru';
            cleanup = '';
        },
        {
            pre = 'cd editsetup; cd presettypes; cd color ';
            cmd  = 'Import "import-feature-colorrgb.xml"'; --at feature 1
            post = '';
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