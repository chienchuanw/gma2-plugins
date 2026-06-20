--*******************************************************************************************
-- This Plugin tests the export fuction for groups. 
-- Group 100,101
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "EXPORT";
    object_name      = "GROUP";
    pre              = 'clearall; delete group 100 + 101 /nc';
    steps =
    {
        {
            smoketest =true;
            pre  = 'Fixture 1 thru ' .. math.floor(fixturecount[2]/3) .. ' + ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+math.floor(fixturecount[2]/4) .. '; store Group 100 /nc';
            cmd  = 'Export group 100 "export-group.xml" /nc';
            post = 'label group 100 "EXP_GRP_1"';
            cleanup = '';
        },
        {
            cmd  = 'Import "export-group.xml" at group 101 /nc';
            post = 'label group 101 "EXP_GRP_2"';
            cleanup = '';
            test = 101;  --comparison of groups
            gold = 201;
        }
    };
};

RegisterTestScript(test);

--*******************************************************************************************
-- module entry point
--*******************************************************************************************

local function StartThisTest()
   fixturecount = get_prop_fixturecount();
   StartSingleTestScript(test);
end

return StartThisTest;