--*******************************************************************************************
-- This script tests the method to delete a channel. -> Unpatch the channel 
-- set on destructive table
-- Sequence 51, DmxSnap 26
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "DELETE";
    object_name      = "CHANNEL";
    pre              = 'ClearAll; delete DmxSnapshot 26 /nc; delete sequence 51 /nc';
    version_script   = '3.2.53.0';
    yield = true;
   
    steps =
    {
        {
            pre  = 'Channel 1 thru ' .. fixturecount[1] .. ' at 100; store sequence 51 cue 1 /nc';
            cmd = 'delete channel 1';
            post = 'label DmxSnapshot 26 "DEL_CH_1"; label Sequence 51 "DEL_CH_1"';
            cleanup = '';
            test_dmx = true;
            test = 26;
            gold = 526;
            destructivetest = true;
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