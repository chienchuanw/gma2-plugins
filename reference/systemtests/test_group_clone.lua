--*******************************************************************************************
-- This script tests the method to clone a group. 
-- Group 21-22, Seq 61
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "CLONE";
    object_name      = "GROUP";
    pre              = 'Clearall; delete Group 21 thru 22 /nc; delete preset 2.10 /nc; delete sequence 61 /nc';
    steps =
    {
        {
        gs_name_step = "SEQUENCE";
        pre  = 'fixture ' .. fixturecount[2]+fixturecount[3]+math.floor(fixturecount[4]/2)+1 .. ' thru ' .. fixturecount[2]+fixturecount[3]+fixturecount[4] .. '; store Group 21 /nc; fixture ' .. fixturecount[2]+fixturecount[3]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3]+fixturecount[4] .. '; store Group 22; ClearAll; group 21; presettype position; attribute "mp_tr_y" at 35; store sequence 61 cue 1 /nc';
        cmd  = 'clone group 21 at 22 if sequence 61 cue 1 /merge /nc';
        post = 'label sequence 61 "CLNE_GRP_1"; label Group 21 "CLNE_GRP_2"; label Group 22 "CLNE_GRP_3"';
        cleanup = '';
        test = 61; --comparison of sequences
        gold = 361;
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