--*******************************************************************************************
-- This script tests the methods to store a layout. 
-- Layout 16-19
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "STORE";
    object_name      = "LAYOUT";
    pre              = 'ClearAll; delete layout 16 thru 19 /nc';
    steps =
    {
        {
            pre  = 'Channel 1 thru ' .. fixturecount[1];
            cmd  = 'store layout 16 /nc';
            post = 'label layout 16 "STORE_LAY_1"';
            cleanup = 'clearall';
            test = 16;  --comparison of layouts
            gold = 116;
        },
        {  --storing by merging
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. ' + ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3]..'; store layout 17 /nc; fixture 1 thru '..math.floor(fixturecount[2]/3);
            cmd  = 'store layout 17 /merge';
            post = 'label layout 17 "STORE_LAY_2"';
            cleanup = 'clearall';
            test = 17;
            gold = 117;
        },
        {  --storing by removing
            pre  = 'Channel 1 thru ' .. fixturecount[1]..'; store layout 18 /nc; channel 1 thru '..fixturecount [2];
            cmd  = 'store layout 18 /remove';
            post = 'label layout 16 "STORE_LAY_3"';
            cleanup = 'clearall';
            test = 18;
            gold = 118;
        },
        {  --storing by overwriting
            pre  = 'Fixture 1 thru; store layout 19 /nc; label layout 19 "STORE_LAY_4"; clearall; channel 1 thru';
            cmd  = 'store layout "STORE_LAY_4" /overwrite';
            cleanup = '';
            test = 19;
            gold = 119;
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