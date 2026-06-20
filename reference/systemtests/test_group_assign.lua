--*******************************************************************************************
-- This script tests the method to assign a group. -> Groupmaster to an Executor 
-- Group 18, Exec 81, DMXsnap 271
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ASSIGN";
    object_name      = "GROUP";
    pre              = 'ClearAll; delete group 18 /nc; delete executor 81 /nc, delete DMXsnapshot 271 /nc';
   
    steps =
    {
        {
            pre  = 'fixture '..math.floor((1*fixturecount[2])/12+1)..' thru '..math.floor((2*fixturecount[2])/12)..'; store group 18; off group 18';
            cmd  = 'assign group 18 at executor 81; assign executor 81 /mode="additive"; tofull exec 81';
            post = 'label group 18 "ASS_GRP_1"; label executor 81 "ASS_GRP_1"';
            cleanup = 'tozero exec 81 /nc';
            test_dmx=true;
            test = 271;
            gold = 771;
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