--*******************************************************************************************
-- This script tests the methods to copy a group  
-- Group 23-31
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "COPY";
    object_name      = "GROUP";
    pre              = 'Clearall; delete Group 23 thru 31 /nc';
   
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. math.floor(fixturecount[2]/2)..'; store group 23; fixture ' .. math.floor(fixturecount[2]/2)+1 .. ' thru ' .. fixturecount[2] .. '; store Group 24';
            cmd  = 'copy Group 23 at 25 /nc';
            post = 'label Group 23 "CPY_GRP_1"; label Group 25 "CPY_GRP_2"';
            cleanup = '';
            test = {23,25}; --comparison of groups
            gold = {123,125};
        },
        {
            cmd  = 'copy Group 23 at 26 thru 28 /nc';
            post = 'label Group 26 "CPY_GRP_3"; label Group 27 "CPY_GRP_4"; label Group 28 "CPY_GRP_5"';
            cleanup = '';
            test = {26,27,28};
            gold = {126,127,128};
        },
        {
            pre  = 'label Group 23 "forluck" ; label Group 24 "framepuck"';
            cmd  = 'copy Group "f*ck" at 30 /o /merge';
            post = 'label Group 30 "CPY_GRP_8"';
            cleanup = '';
            test = 30;
            gold = 130;
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