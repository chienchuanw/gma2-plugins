--*******************************************************************************************
-- This script tests the method to start an agenda entry manually. 
-- Agenda Testing is only working if there is a successive growing of agenda numbers.
-- If single tests are executed, consider the possibility of errors.
-- Agenda 2, DmxSnap 20, Seq 50
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "AGENDA";
    object_name      = "AGENDA";
    pre              = 'ClearAll; delete DmxSnapshot 20 /nc; delete sequence 50 /nc; cd /; cd "Agendas"; delete 2 /nc';
    version_script   = '3.2.55.2';
    exit_cmd         = 'cd /';
   
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 100; store sequence 50 cue 1; store 2; assign 2 /CMD="go sequence 50"; clearall';
            cmd  = 'agenda 2';
            post = 'label DmxSnapshot 20 "AGD_AGD"; label sequence 50 "AGD_AGD"';
            cleanup = '';
            test_dmx = true;
            test = 20;
            gold = 520;
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