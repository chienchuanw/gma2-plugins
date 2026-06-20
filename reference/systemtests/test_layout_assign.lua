--*******************************************************************************************
-- This script tests the operation assign for layouts. 
-- If a layout is assigned at an executor a groupmaster is made.
-- This operation is possible but not meant to be used like this.
-- Layout 22, Sequ 191, Executor 91
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ASSIGN";
    object_name      = "LAYOUT";
    pre              = 'ClearAll; delete layout 22 /nc; delete sequence 191 /nc; delete executor 91 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' ..fixturecount[2].. '; store layout 22';
            cmd  = 'assign layout 22 at executor 91';
            post = 'off layout 22; selfix executor 91; feature colorrgb at 28; store sequence 191 cue 1 /nc; label sequence 191 "ASS_LAY_1"; label layout 22 "ASS_LAY_1"; label executor 91 "ASS_LAY_1"';
            cleanup = '';
            test = 22;   --comparing layouts
            gold = 122;
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