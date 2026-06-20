--*******************************************************************************************
-- This script tests the methods to copy a DmxSnapshot 
-- Basic function of the test matrix.
-- DmxSnap 6-7
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "COPY";
    object_name      = "DMXSNAPSHOT";
    pre              = 'ClearAll; delete DmxSnapshot 6 + 7 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre = 'Fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. '; store DmxSnapshot 6; Fixture ' .. math.floor(fixturecount[2]/2)+1 .. ' thru ' .. fixturecount[2] .. '; store DmxSnapshot 7';
            cmd  = 'copy DmxSnapshot 6 at 7 /nc';
            post = 'label DmxSnapshot 6 "CPY_DMXS_1"; label DmxSnapshot 7 "CPY_DMXS_3"';
            cleanup = '';
            test = {6,7};
            gold = {506,506};
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