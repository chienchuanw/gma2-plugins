--*******************************************************************************************
-- This script tests the method top for a page.
--  Page 72, Seq 194, DmxSnapshot 280+281
--*******************************************************************************************

local test=
{
    method_name     = "TOP";
    object_name     = "PAGE";
    pre             = 'Delete Page 72 /nc; store page 72; Page 72; Label Page 72 "TOP_PAG"; delete seq 194 /nc';
    steps =
    {
        {
            -- 'Top' Page with Sequence (2 Cues)
            pre  = 'Channel thru Full; Store Seq 194; at 42; store seq 194 /a; Assign Seq 179 at Exec 72.1; Clearall';
            cmd  = 'Top Page 72';
            post = 'Label DmxSnapshot 280 "TOP_PAG_1"; Label Exec 72.1 "TOP_PAG_1"; Label Seq 194 "TOP_PAG_1"; Label Page 72 "TOP_PAG_1"';
            cleanup = 'off page 72; page 1';
            test_dmx = true;
            test = 280;
            gold = 281; -- channels at full
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