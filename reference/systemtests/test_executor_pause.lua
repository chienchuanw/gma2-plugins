--*******************************************************************************************
-- This script tests the method pause for an executor.
-- Additional for an effect assigned on an executor.
-- Additional for a chaser assigned on an executor.
--
-- Exec 49-51, Seq 146,147, Effect 102, DmxSnap 144-146
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "PAUSE";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete DmxSnapshot 144 thru 146 /nc; delete sequence 146 + 147 /nc; delete executor 49 thru 51 /nc; delete effect 102 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 20; store sequence 146 cue 1 fade 20; assign sequence 146 at executor 49; clearall; go executor 49';
            pre_func = function () gma.echo('sleeping for 2 seconds'); gma.sleep(2); gma.echo('done'); end;
            cmd  = 'pause executor 49';
            post = 'label sequence 146 "PAU_EXEC_1"; label executor 49 "PAU_EXEC_1"; label DmxSnapshot 144 "PAU_EXEC_1"';
            cleanup = '';
            test_dmx = true;
            test = 144;
            gold = 644;
        },
        --tests pause on an executor with an effect
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. ' at 80; Presettype "Dimmer"; at form "ramp"; at effectBPM 1; store Effect 102; ClearAll; assign Effect 102 at executor 50 /effectspeed=on; go executor 50';
            pre_func = function () gma.echo('sleeping for 2 second'); gma.sleep(2); gma.echo('done'); end;
            cmd  = 'pause executor 50';
            post = 'label executor 50 "PAU_EXEC_2"; label DmxSnapshot 145 "PAU_EXEC_2"; label effect 102 "PAU_EXEC_2"';
            cleanup = '';
            test = 145;
            gold = 645;
        },
        --tests pause on an executor with as chaser
        
        --timing problems in comparision
        --[[{
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. ' at 30; store sequence 147 cue 1 /nc; Fixture 1 thru ' .. fixturecount[2] .. ' at 80; store sequence 147 cue 2/nc; Fixture 1 thru ' .. fixturecount[2] .. ' at 99; store sequence 147 cue 3/nc; assign sequence 147 at executor 51; assign executor 51 /chaser=on; clearall; go executor 51';
            pre_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); gma.echo('done'); end;
            cmd  = 'pause executor 51';
            post = 'label executor 51 "PAU_EXEC_3"; label DmxSnapshot 146 "PAU_EXEC_3"; label sequence 147 "PAU_EXEC_3"';
            cleanup = 'cd /; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru';
            test_dmx = true;
            test = 146;
            gold = 646;
        },]]
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