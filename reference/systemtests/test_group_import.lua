--*******************************************************************************************
-- This Plugin tests the export fuction for groups. 
-- Group 102
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "IMPORT";
    object_name      = "GROUP";
    pre              = 'clearall; delete group 102 /nc';
    steps =
    {
        {
            pre  = 'Fixture ' .. math.floor(fixturecount[2]/3) .. ' thru ' .. fixturecount[2] .. ' + ' .. fixturecount[2]+math.floor(fixturecount[2]/4) .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; store Group 102';
            cmd  = 'Import "import-group.xml" at group 102 /nc';
            post = 'label group 102 "IMP_GRP_1"';
            cleanup = '';
            test = 102;
            gold = 302;
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