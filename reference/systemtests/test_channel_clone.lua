--*******************************************************************************************
-- This script tests the method to clone a channel. 
-- Seq 52, Exec 2, DmxSnap 23
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "CLONE";
    object_name      = "CHANNEL";
    pre              = 'Clearall; page 1; delete sequence 52 /nc; delete executor 2 /nc; delete DmxSnapshot 23 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'channel 1 thru ' .. math.floor(fixturecount[1]/2) .. ' - 3 at 50; store sequence 52 cue 1 + 3 + 5 /nc; assign sequence 52 at executor 2';
            cmd  = 'clone channel 1 at 3 if sequence 52 cue 1 /merge /nc; Clearall; go executor 2 cue 1'; -- now channel 3 is 50 in cue 1, too
            post = 'label sequence 52 "CLNE_CH_1"; label executor 2 "CLNE_CH_1"; label DmxSnapshot 23 "CLNE_CH_1"';
            cleanup = '';
            test_dmx = true;
            test = 23;
            gold = 523;
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