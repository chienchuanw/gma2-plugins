--*******************************************************************************************
-- This script tests the method solo to a selection 
-- DmxSnap 429,430
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "SOLO";
    object_name      = "SELECTION";
    version_script   = "3.1.145.4";
    pre              = 'ClearAll; delete DmxSnapshot 429 + 430 /nc; solo off; ';
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2]+fixturecount[3] .. ' at 100; Fixture 1 thru ' .. fixturecount[2];
            cmd  = 'solo Selection';
            post = 'label DmxSnapshot 429 "SOLO_SELE_1"';
            cleanup= 'clearall; off page thru';
            test_dmx = true;
            test = 429;
            gold = 729;
        },
        {
            pre  = 'solo off; Fixture 1 thru ' .. fixturecount[2]+math.floor(fixturecount[2]/2);
            cmd  = 'solo on Selection';
            post = 'label DmxSnapshot 430 "SOLO_SELE_2"';
            cleanup = 'solo off';
            test_dmx = true;
            test = 430;
            gold = 730;
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