--*******************************************************************************************
-- This script tests the method insert to a group 
-- Inserting at an occupied position moves the following.
-- Group 34-38
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "INSERT";
    object_name      = "GROUP";
    pre              = 'clearall; delete group 34 thru 38 /nc';
    steps =
    {
        {
            --inserting a group at a place which is occupied
            pre  = 'Channel 1 thru ' .. fixturecount[1] .. '; store group 34; fixture 1 thru ' .. fixturecount[2] .. '; store group 35 /nc;';
            cmd  = 'Insert group 34 at 35';    --group 35 and group 34 are swapped
            post = 'label group 34 "INS_GRP_1"; label group 35 "INS_GRP_2"';
            cleanup = '';
            test = {34,35};
            gold = {134,135};
        },
        {
            --inserting  groups at a place which is available, group 36 is a gap
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. '; store group 37; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] ..'; store group 38 /nc';
            cmd  = 'Insert group 38 at 36'; --the gap should be closed, nothing swapped
            post = 'label group 36 "INS_GRP_3"; label group 37 "INS_GRP_4"; label group 38 "INS_GRP_5"';
            cleanup = '';
            test = {36,37,38};
            gold = {136,137,138};
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