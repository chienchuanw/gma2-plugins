--*******************************************************************************************
-- This script tests the method to assign a channel. -> Channelfader
-- DmxSnap 21
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ASSIGN";
    object_name      = "CHANNEL";
    pre              = 'ClearAll; delete dmxsnapshot 21 /nc; channelpage +';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Channel 1 thru ' .. fixturecount[1]..' at 68';
            cmd  = 'Assign Channel 1 thru ' .. fixturecount[1] .. ' at ChannelFader 1 thru ';
            post = 'label DmxSnapshot 21 "ASS_CH_1"';
            cleanup = 'channelpage -; Off channelfader thru';
            test_dmx = true;
            test = 21;
            gold = 521;
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