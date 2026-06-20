--*******************************************************************************************
-- This script tests the methods to store a DmxSnapshot. This exsists since v2.8 
-- Basic function of the test matrix.
-- A DmxSnapshot is already the stored output. 
-- The store cmd does not change anything at the output here.
-- DmxSnap 1-2
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "STORE";
    object_name      = "DMXSNAPSHOT";
    pre              = 'ClearAll; delete DmxSnapshot 1+2 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Channel 1 thru ' .. fixturecount[1] .. ' at 50 thru 0';
            cmd  = 'store DmxSnapshot 1 ';
            post = 'label DmxSnapshot 1 "STO_DMXS_1"';
            cleanup = '';
            test_dmx= true;
            test = 1;
            gold = 501;
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