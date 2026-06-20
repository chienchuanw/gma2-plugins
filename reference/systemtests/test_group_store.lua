--*******************************************************************************************
-- This script tests the methods to store a group. It contains a blacktest, which tests that
-- order and containing fixtures are tested right. 
-- Group 3 - 11
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "STORE";
    object_name      = "GROUP";
    pre              = 'ClearAll; delete Group 3 thru 11 /nc';

    steps =
    {
        {
            pre  = 'Channel 1 thru ' .. fixturecount[1];
            cmd  = 'store Group 3 /nc';
            post = 'label Group 3 "GRP_STO_1"';
            cleanup= 'ClearAll';
            test = 3;   --comparison of groups
            gold = 87;
        },
        {  --storing many groups
            pre  = 'fixture 1 thru ' .. fixturecount[2]+1;
            cmd  = 'store Group 5 thru 8 /nc';
            post = 'label Group 5 thru 8 "GRP_STO_2"';
            cleanup='ClearAll';
            test = {5,6,7,8};
            gold = {88,89,90,91};
        },
        {  --storing by removing
            pre  = 'fixture 1 thru ' .. fixturecount[2]..' ; store group 9 /nc; fixture 1 thru ' .. (fixturecount[2]+fixturecount[3]);
            cmd  = 'store Group 9 /remove';
            post = 'label Group 9 "GRP_STO_3"';
            cleanup ='ClearAll';
            test = 9;
            gold = 92;
        },     
        {  --storing by overwriting
            pre  = 'fixture ' ..math.floor(fixturecount[2]/3) .. ' thru ' ..fixturecount[2]..'; store group 10 /nc; fixture 1 thru ' ..math.floor(fixturecount[2]/4);
            cmd  = 'store Group 10 /overwrite';
            post = 'label Group 10 "GRP_STO_4"';
            cleanup ='ClearAll';
            test = 10;
            gold = 93;
        },
        {  --storing by merging
            pre  = 'fixture ' ..math.floor(fixturecount[2]/3) .. ' thru ' ..fixturecount[2]..'; store group 11 /nc; fixture 1 thru ' ..math.floor(fixturecount[2]/4);
            cmd  = 'store Group 11 /merge';
            post = 'label Group 11 "GRP_STO_4"';
            cleanup = '';
            test = 11;
            gold = 94;
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