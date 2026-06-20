--*******************************************************************************************
-- This script tests the methods to store an effect. 
-- Effect 20-23
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "STORE";
    object_name      = "EFFECT";
    pre              = 'ClearAll; delete effect 20 thru 23 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2]+fixturecount[3] .. '; channel thru; Presettype "Dimmer"; at form "sin"; at effectBPM 180';
            cmd  = 'store Effect 20; assign effect 20 /blocks = 5';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 20 "Dim Sin"';
            cleanup = 'off effect thru';
            test = 20;  --comparsision of effects
            gold = 220;
        },
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. '; Attribute "Colorrgb1"; at form "Phase 1"; at effectBPM 60; Attribute "Colorrgb2"; at form "Phase 2"; at effectBPM 60; Attribute "Colorrgb3"; at form "Phase 3"; at effectBPM 60';
            cmd  = 'store Effect 21; assign effect 21 /Phase = "0.0..-360.0"';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 21 "Color Phase"';
            cleanup = 'off effect thru';
            test = 21;
            gold = 221;
        },
        {
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; Attribute "pan"; at form "circle"; at effectBPM 35; Attribute "tilt"; at form 22.2; at effectBPM 35';
            cmd  = 'store Effect 22';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 22 "P/T Cricle"';
            cleanup = 'off effect thru';
            test = 22;
            gold = 222;
        },
        {
            pre  = 'selfix fixture ' .. fixturecount[2]+fixturecount[3]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3]+fixturecount[4] .. '; Attribute "MP_TR_Z"; at form "ramp"; at effectBPM 35';
            cmd  = 'store Effect 23 /mode= "rel" /nc';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 23 "Path MoveZ"';
            cleanup= 'off effect thru; clearall; cd /; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru';
            test = 23;
            gold = 223;
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