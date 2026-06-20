--*******************************************************************************************
-- This Plugin tests the at function for groups.
 -- Group 19-20
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name         = "AT";
    object_name         = "GROUP";
    pre                 = 'clearall; delete Group 19 thru 20 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre         = 'Fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; store Group 19 /nc; Group 19 at 100; Fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; store Group 20 /nc ';
            cmd         = 'Group 20 at Group 19';
            post        = 'label Group 19 "AT_GRP_1"; label group 20 "AT_GRP_2"';
            cleanup = '';
            test        = {19,20};
            gold        = {119,120};
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