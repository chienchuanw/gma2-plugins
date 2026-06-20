--*******************************************************************************************
-- This script test the multiple options storing a cue.
-- Seq 70, DMXsnap 45 -49
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "STORE";
    object_name      = "CUE";
     version_script   = "3.1.70.1";
    pre              = 'Clearall; delete sequence 70 /nc; delete dmxsnapshot 45 thru 49 /nc';
    steps =
    {
        {
            --storing a cue
            pre  = 'fixture 1 thru '..fixturecount[2]..' at 40';
            cmd  = 'store sequence 70 cue 1 /use=all; clearall; go sequence 70';
            post = 'label sequence 70 "CUE_STO"; label sequence 70 cue 1 "store"; label DMXsnapshot 45 "CUE_STO_1"';
            cleanup = '';
            test_dmx= true;
            test = 45;
            gold = 545;
        },
        {
            --storing a cue by merging
            pre  = 'fixture 4 thru '..fixturecount[2]..' at 55; store sequence 70 cue 2; fixture 4 thru '..fixturecount[2]..' at 65';
            cmd  = 'store sequence 70 cue 2 /merge; clearall; goto sequence 70 cue 2';
            post = 'label sequence 70 cue 2 "merge"; label DMXsnapshot 46 "CUE_STO_2"';
            cleanup = '';
            test_dmx= true;
            test = 46;
            gold = 546;
        },
        {
            --storing a cue by overwriting
            pre  = 'fixture 4 thru '..fixturecount[2]..' at 56; store sequence 70 cue 3; fixture 4 thru '..fixturecount[2]..' at 66';
            cmd  = 'store sequence 70 cue 3 /overwrite; clearall; goto sequence 70 cue 3';
            post = 'label sequence 70 cue 3 "overwrite"; label DMXsnapshot 47 "CUE_STO_3"';
            cleanup = '';
            test_dmx= true;
            test = 47;
            gold = 547;
        },
        {
            --storing a cue with statusmerge
            pre  = 'fixture 4 thru '..fixturecount[2]..' at 77; store sequence 70 cue 4; fixture 4 thru '..fixturecount[2]..' at 88';
            cmd  = 'store sequence 70 cue 4 /statusmerge; clearall; goto sequence 70 cue 4';
            post = 'label sequence 70 cue 4 "statusmerge"; label DMXsnapshot 48 "CUE_STO_4"';
            cleanup = '';
            test_dmx= true;
            test = 48;
            gold = 548;
        },
        {
            --storing a cue with cueonly
            pre  = 'fixture 4 thru '..fixturecount[2]..' at 77';
            cmd  = 'store sequence 70 cue 5 /cueonly; clearall; goto sequence 70 cue 5';
            post = 'label sequence 70 cue 5 "cueonly"; label DMXsnapshot 49 "CUE_STO_5"';
            cleanup = '';
            test_dmx= true;
            test = 49;
            gold = 549;
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