--*******************************************************************************************
-- This script tests the method "off" for a page.
-- Page 9, Group 107, Effect 5, Macro 35, Sequ 168, DmxSnapshot 224-235
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test=
{
    method_name     = "OFF";
    object_name     = "PAGE";
    pre             = 'ClearAll; delete page 9 /nc; page 9; label page 9 "OFF_PAG"; delete group 107 /nc; delete effect 5 /nc; delete macro 35 /nc; delete seq 168 /nc; delete DmxSnapshot 224 thru 229';
    steps =
    {
        {
            -- 'Off' Page with Sequence
            pre  = 'Channel 1 thru ' .. fixturecount[1] .. ' at Full; Store Seq 168; Assign Seq 168 at Exec 9.1; On Exec 9.1';
            cmd  = 'Off Page 9';
            post = 'Label DmxSnapshot 224 "OFF_PAG_1"; Label Exec 9.1 "OFF_PAG_1"; Label Page 9 "OFF_PAG_1"';
            test_dmx = true;
            test = 224;
            gold = 230;
        },
        {
            --'Off' Page with Group Master (off command does not work with group masters so it should stay full)
            pre  = 'fixture '..math.floor((6*fixturecount[2])/12+1)..' thru '..math.floor((7*fixturecount[2])/12)..'; Store Group 107 /o; Assign Group 107 At Exec 9.2; assign exec 9.2 /mode="additive"; tofull exec 9.2';
            cmd  = 'Off Page 9';
            post = 'Label DmxSnapshot 225 "OFF_PAG_2"; Label Page 9 "OFF_PAG_2"; Label Group 107 "OFF_PAG_2"';
            cleanup = 'tozero exec 9.2 /nc';
            test_dmx = true;
            test = 225;
            gold = 231;
        },
        {
            -- 'Off' Page with Special Master
            pre  = 'Assign SpecialMaster 1.1 At Exec 9.3; On Exec 9.3';
            cmd  = 'Off Page 9';
            post = 'Label DmxSnapshot 226 "OFF_PAG_3"; Label Page 9 "OFF_PAG_3"';
            test_dmx = true;
            test = 226;
            gold = 232;
        },
        {
            -- 'Off' Page with Effect
            pre  = 'fixture thru; channel thru; at form "sin"; at effectBPM 180; Store Effect 5 /o; Assign Effect 5 At Exec 9.4; Clearall; On Exec 9.4';
            cmd  = 'Off Page 9';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'Label DmxSnapshot 227 "OFF_PAG_4"; Label Page 9 "OFF_PAG_4"; Label Effect 5 "OFF_PAG_4"';
            test_dmx = true;
            test = 227;
            gold = 233;
        },
        {
            -- 'Off' Page with Macro
            pre  = 'store macro 1.35; store macro 1.35.1; assign macro 1.35.1 /cmd="channel 1 thru ' .. fixturecount[1] .. ' at 45"; Assign Macro 35 at Exec 9.5; On Exec 9.5';
            cmd  = 'Off Page 9';
            post = 'Label DmxSnapshot 228 "OFF_PAG_5"; Label Page 9 "OFF_PAG_5"; Label Macro 35 "OFF_PAG_5"';
            test_dmx = true;
            test = 228;
            gold = 234;
        },
        {
            -- 'Off' Page with Timer
            pre  = 'Assign Timer 1 At Exec 9.6; On Exec 9.6';
            cmd  = 'Off Page 9';
            post = 'Label DmxSnapshot 229 "OFF_PAG_6"; Label Page 9 "OFF_PAG"';
            cleanup = 'page 1';
            test_dmx = true;
            test = 229;
            gold = 235;
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