--*******************************************************************************************
-- This script tests the method to store an agenda object. 
-- Agenda Testing is only working if there is a successive growing of agenda numbers.
-- If single tests are executed, consider the possibility of errors.
-- THIS IS A SMOKE TEST! No cpoying and no comparison.
-- Agendas are in collects not in pools!
-- Agenda 1
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "STORE";
    object_name      = "AGENDA";
    pre              = 'ClearAll; cd /; cd "Agendas"; delete 1 /nc';
    version_script   = '3.2.55.2';
    exit_cmd         = 'cd /';
   
    steps =
    {
        {
            smoketest= true;
            cmd  = 'store 1; assign 1 /start=Absolute /time=12h00m00s /duration=00h00m05s /repeat=daily /CMD="fixture 1 thru '..fixturecount[2]..' at 70" /info="First Agenda entry" /first=01/01/2017 /last=02/11/2024';
            cleanup = '';
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