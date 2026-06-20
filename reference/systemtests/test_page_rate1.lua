--*******************************************************************************************
-- This script tests the method to set a page to rate 1.
-- Page 19, Page 93, Seq 187
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test=
{
    method_name     = "RATE1";
    object_name     = "PAGE";
    pre             = 'ClearAll; delete page 19 /nc; page 19; delete seq 187 /nc;';
    steps =
    {
        {
            -- Set Page 19 to Rate 1
            smoketest = true;
            pre  = 'channel thru at 42; store seq 187; assign seq 187 at exec 19.1; exec 19.1';
            cmd  = 'rate1 page 19';
            post = 'label sequence 187 "RAT_PAG_1"; label executor 19.1 "PAU_PAG_1"; label page 19 "RAT_PAG_1"';
            cleanup = 'page 1';
            -- test = 19;
            -- gold = 93;
        },
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