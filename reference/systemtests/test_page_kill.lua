--*******************************************************************************************
-- This script tests the method kill for a page.
-- Page 16-17, Sequ 182-184, DmxSnapshot 218-223
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test=
{
    method_name     = "KILL";
    object_name     = "PAGE";
    pre             = 'ClearAll; delete page 16 + 17 /nc; page 16; Label Page 16 KIL_PAG; Label Page 17 KIL_PAG; delete seq 182 thru 184 /nc; delete DmxSnapshot 218 thru 220 /nc';
    steps =
    {
        {
            -- 'Kill' Page with Sequence
            pre  = 'Channel thru at Full; Store Seq 182; at form "sin"; at effectBPM 0; store seq 183; Assign Seq 182 at Exec 16.101; page 17; Assign Seq 183 at Exec 17.101; Go Page 16 + 17';
            cmd  = 'Kill Page 16';
            post = 'Label DmxSnapshot 218 "KIL_PAG_1"; Label Exec 16.101 "KIL_PAG_1.1"; Label Exec 17.101 "KIL_PAG_1.2"; Label Seq 182 "KIL_PAG_1.1"; Label Seq 183 "KIL_PAG_1.2"; Label Page 16 "KIL_PAG_1.1"; Label Page 17 "KIL_PAG_1.2"';
            test_dmx = true;
            test = 218;
            gold = 221; -- Exec on Page 16 on, Exec on Page 17 off
        },
        {
            pre  = 'Go Page 16 + 17';
            cmd  = 'Kill Page 17';
            post = 'Label DmxSnapshot 219 "KIL_PAG_2"; Label Exec 16.101 "KIL_PAG_2.1"; Label Exec 17.101 "KIL_PAG_2.2"; Label Seq 182 "KIL_PAG_2.1"; Label Seq 183 "KIL_PAG_2.2"; Label Page 16 "KIL_PAG_2.1"; Label Page 17 "KIL_PAG_2.2"';
            test_dmx = true;
            test = 219;
            gold = 222; -- Exec on Page 16 off, Exec on Page 17 on
        },
        {
            -- add second executor (last executor will be started!)
            pre  = 'Page 16; Channel thru; at form "sin"; at effectBPM 0; store seq 184; Assign Seq 184 at Exec 16.102; Go Page 16 + 17';
            cmd  = 'Kill Page 16';
            post = 'Label DmxSnapshot 220 "KIL_PAG_3"; Label Exec 16.102 "KIL_PAG_3"; Label Seq 184 "KIL_PAG_3"; Label Page 16 "KIL_PAG_3"; Label Page 17 "KIL_PAG_3"';
            cleanup = 'Page 1';
            test_dmx = true;
            test = 220;
            gold = 223; -- Last Exec on Page 16 on, other Execs off
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