--*******************************************************************************************
-- This script tests the method to clone a fixture. 
-- Seq 171, DmxSnap 244+245
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "CLONE";
    object_name      = "FIXTURE";
    pre              = 'Clearall; delete sequence 171 /nc; delete DmxSnapshot 244+245 /nc'; 
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'fixture 1 at 75; store sequence 171 cue 1 /nc';  --if (only what fixture 1 does in sequence 171)
            cmd  = 'clone fixture 1 at fixture 5 thru 33 if sequence 171 cue 1 /overwrite /nc; clearall; go sequence 171';
            post = 'label DmxSnapshot 244 "CLNE_FIX_1"';
            cleanup = '';
            test_dmx = true;
            test = 244;
            gold = 744;
        },
        --[[{
            pre = ' fixture ' .. fixturecount[2]+math.floor(fixturecount[2]/2)+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 75; store sequence 171 cue 2 + 4  /overwrite /nc';
            cmd  = 'clone fixture ' .. fixturecount[2]+fixturecount[3] .. ' at ' .. fixturecount[2]+1 .. ' if sequence 171 cue 2 /lowmerge /nc';
            post = 'label DmxSnapshot 245 "CLNE_FIX_2"';
            test_dmx = true;
            test = 245;
            gold = 745;
        }]]
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