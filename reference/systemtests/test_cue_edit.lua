--*******************************************************************************************
-- This script tests the methods to edit a cue. 
-- Seq 76, Exec 208
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "EDIT";
    object_name      = "CUE";
    pre              = 'ClearAll; delete executor 208 /nc; delete sequence 76 cue 1 thru cue 99 /nc';
    steps=
    {
        {
            pre  = 'fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. ' at 50; store sequence 76 cue 1 /use=active /nc; store sequenec 76 cue 101; assign sequence 76 at executor 208; select executor 208';
            cmd  = 'edit sequence 76 cue 1; fixture 1 thru ' .. (fixturecount[2]*2) .. ' at 45; edit sequence 76 cue 1 /nc; update sequence 76 cue 1 /nc';
            post = 'label sequence 76 "CUE_EDIT"; label sequence 76 cue 101 "golden cue list from here"';
            cleanup = '';
            test = 1;
            gold = 101.1;
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