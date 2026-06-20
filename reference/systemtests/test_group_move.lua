--*******************************************************************************************
-- This script tests the move operation in a group pool.
-- Group 39-44
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "MOVE";
    object_name      = "GROUP";
    pre              = 'clearall; delete Group 39 thru 44 /nc';
    steps =
    {
        {  --moving to an avialable position
            pre = 'Fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. '; store Group 39 /nc';
            cmd  = 'Move group 39 at 40 /nc';  --group position 39 is now empty
            post = 'label group 40 "MOV_GROUP_1"; label Group 40 "MOV_GROUP_1"';
            cleanup = '';
            test = 40;
            gold = 140;
        },
        {  --moving by label to an avialable position
            pre  = 'Fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. '; store Group 41 /nc; label group 41 "MOV_GROUP_2"';
            cmd  = 'Move group "MOV_GROUP_2" at group 42 /nc'; 
            cleanup = '';
            test = 42;
            gold = 142;
        },
        {  --moving at an occupied position
            version_step = "3.3.0.0";  
            pre  = 'Fixture 1 thru ' .. math.floor(fixturecount[2]/3) .. '; store group 43 /nc; Fixture ' .. math.floor(fixturecount[2]/2)+1 .. ' thru ' .. fixturecount[2] .. ' ; store Group 44 /nc; clearall';
            cmd  = 'Move group 43 at group 44 /nc';  --moving and swapping
            post= 'label group 44 "MOV_GROUP_3"';
            cleanup = '';
            test = {43,44};
            gold = {143,144};
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