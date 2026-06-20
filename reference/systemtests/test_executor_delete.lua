--*******************************************************************************************
-- This script tests the deleting of Executors. 
-- Exec 14-17, Seq 125+126
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "DELETE";
    object_name      = "EXECUTOR";
    pre              = 'clearall; Delete sequence 125 thru 126 /nc; delete executor 14 thru 17 /nc';
    steps=
    {
        {
            pre  = 'Fixture ' .. math.floor(fixturecount[2]/4)+1 .. ' thru ' .. math.floor(fixturecount[2]/2) .. ' at 50; Store sequence 125 cue 1; Fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. ' at 0; Store sequence 125 cue 2 /nc; assign sequence 125 at executor 14';
            cmd  = 'delete executor 14';
            post = 'Label sequence 125 "DEL_EXEC_1"';
            cleanup = '';
            test = 14;
            gold = -1;
        },
        {
            pre = 'Fixture 1 thru ' .. math.floor(fixturecount[2]/4) .. ' at 50; Store sequence 126 Cue 1; Assign sequence 126 executor 15 thru 17';
            cmd  = 'delete executor 15 thru 17';
            post = 'label sequence 126 "DEL_EXEC_2"; label executor 14 "DEL_EXEC_2"';
            cleanup = '';
            test = {15,16,17};
            gold = {-1,-1,-1};
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