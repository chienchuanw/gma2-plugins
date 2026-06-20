--*******************************************************************************************
-- This script tests the methods to update a cue.
-- Seq 87, Exec 13
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UPDATE";
    object_name      = "CUE";
    pre              = 'ClearAll; delete sequence 87 cue 1 thru cue 99 /nc; delete executor 13 /nc; store sequence 87 cue 101 /use=all /nc';
    steps =
    {
        {
            pre  = 'select executor 13; assign sequence 87 executor 13; fixture 1 thru ' .. math.floor(fixturecount[2]/4) .. ' at 50; store sequence 87 cue 1 /use=active /nc; fixture ' .. fixturecount[2] .. ' at 100; store sequence 87 cue 2 /nc; fixture ' .. math.floor(fixturecount[2]/4)+1 .. ' thru ' .. math.floor(fixturecount[2]/2) .. ' at 50; store sequence 87 cue 3 /nc; fixture ' .. math.floor(fixturecount[2]/4)+1 .. ' thru ' .. math.floor(fixturecount[2]/2) .. ' at 100';
            cmd  = 'update sequence 87 cue 2 /addnewcontent=false /tracking=false';
            post = 'label sequence 87 "CUE_UPD"; label sequence 87 cue 101 "golden cue list from here"';
            cleanup = '';
            test = 2;
            gold = 102.1;
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