--*******************************************************************************************
-- This script tests the method to assign a preset to default and highlight values. 
-- Preset 1.1, 1.2 DmxSnap 349 + 350
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ASSIGN";
    object_name      = "PRESET";
    pre              = 'ClearAll; highlight off; delete preset 1.1 thru 1.3 /nc; delete DmxSnapshot 349 + 350 /nc';
   
    steps =
    {
        {  
            pre  = 'Channel 1 thru ' .. fixturecount[1] .. ' at 20; store preset 1.1';
            cmd  = 'assign preset 1.1 /special=default';
            post = 'label preset 1.1 "ASS_PRES_1"';
            cleanup ='clearall';
            test = 1.1;
            gold = 1.101;
        },
        {
            --version_step   = '3.2.53.0';
            pre  = 'Channel 1 thru ' .. fixturecount[1];
            cmd  = 'Preset 1.1';
            post = 'label DmxSnapshot 349 "PRES_ASS_1"';
            cleanup ='clearall';
            test_dmx = true;
            test = 349;
            gold = 849;
        },
        {
            pre  = 'Channel 1 thru ' .. math.floor(fixturecount[1]/2) .. ' at 70; store preset 1.2';
            cmd  = 'assign preset 1.2 /special=highlight';
            post = 'label preset 1.2 "ASS_PRES_2"';
            cleanup ='clearall';
            test = 1.2;
            gold = 1.102;
        },
        {
            version_step   = '3.2.53.0';
            pre  = 'Channel 1 thru ' .. math.floor(fixturecount[1]/3);
            cmd  = 'Preset 1.2; highlight on';
            post = 'label DmxSnapshot 350 "PRES_ASS_2"';
            cleanup = 'highlight off';
            test_dmx = true;
            test = 350;
            gold = 850;
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