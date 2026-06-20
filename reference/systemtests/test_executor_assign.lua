--*******************************************************************************************
-- This script tests the possibilities to assign objects to Executors
-- Exec 17+18, Seq 105+106, DmxSnap 122+165-206, Effect 50
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ASSIGN";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete sequence 105+106 /nc; delete executor 17+18 /nc; delete DmxSnapshot 122+165 thru 206 /nc; delete effect 50 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 100; store sequence 105 cue 1';
            cmd  = 'Assign sequence 105 at executor 17; clearall; go executor 17';
            post = 'label executor 17 "ASS_EXEC_1"; label DmxSnapshot 122 "ASS_EXEC_1"; label sequence 105 "ASS_EXEC_1"';
            cleanup = '';
            test_dmx = true;
            test = 122;
            gold = 622;
        },
        -- Testing assigning button functions
        {
            cmd  = 'Assign Go ExecButton1 17; Assign Temp ExecButton2 17; Assign Toggle ExecButton3 17; Assign Speed at executor 17; go executor 17';
            post= 'Assign Master at executor 17';
            test = 18;
            gold = 80;
        },
        -- Testing start/stop options
        {
            pre  = 'Assign executor 17 /autostart=off';
            cmd  = 'executor 17 at 100';
            post = ' label DmxSnapshot 165 "ASS_EXEC_3"';
            cleanup = 'off executor 17';
            test_dmx = true;
            test = 165;
            gold = 665;
        },
        {
            pre  = 'Assign executor 17 /autostart=on';
            cmd  = 'executor 17 at 1';
            post = 'off executor 17; label DmxSnapshot 166 "ASS_EXEC_4"';
            test_dmx = true;
            test = 166;
            gold = 666;
        },
        {
            pre  = 'Assign executor 17 /autostop=off; executor 17 at 1; on executor 17';
            cmd  = 'executor 17 at 0';
            post = 'off executor 17; label DmxSnapshot 167 "ASS_EXEC_5"';
            test_dmx = true;
            test = 167;
            gold = 667;
        },
        {
            pre  = 'Assign executor 17 /autostop=on; executor 17 at 1; on executor 17';
            cmd  = 'executor 17 at 0';
            post = 'off executor 17; label DmxSnapshot 168 "ASS_EXEC_6"';
            test_dmx = true;
            test = 168;
            gold = 668;
        },
        -- Testing auto fix
        {
            pre  = 'Assign executor 17 /autofix=on; Go executor 17; page 2; Assign sequence 97 at executor 1.18; executor 17 at 100';
            pre_func = function() gma.echo('Sleeping for 1 second'); gma.sleep(1); end;
            cmd  = 'executor 17 at 75';
            post = 'label executor 1.18 "ASS_EXEC_7"; label DmxSnapshot 169 "ASS_EXEC_7"';
            cleanup= 'off executor thru; page 1';
            test_dmx = true;
            test = 169;
            gold = 669;
        },
        -- Testing master Go/Top/On
        {
            pre  = 'Assign executor 17 /autofix=off /autostop=off /autostart=off /MasterGo=Go; Off executor 17; executor 17 at 0; go executor 17';
            cmd  = 'executor 17 at 30';
            post = 'label DmxSnapshot 170 "ASS_EXEC_8"';
            test_dmx = true;
            test = 170;
            gold = 670;
        },
        {
            pre  = 'Assign executor 17 /MasterGo=Top; executor 17 at 0';
            cmd  = 'executor 17 at 30';
            post = 'label DmxSnapshot 171 "ASS_EXEC_9"';
            test_dmx = true;
            test = 171;
            gold = 671;
        },
        {
            pre  = 'Go executor 17; Go executor 17; Go executor 1.17; Assign executor 17 /MasterGo=On; executor 17 at 0';
            cmd  = 'executor 17 at 100';
            post = ' label DmxSnapshot 172 "ASS_EXEC_10"';
            cleanup ='off executor thru ';
            test_dmx = true;
            test = 172;
            gold = 672;
        },
        -- Testing loop breaking go
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 50; store sequence 105 cue 2; fixture 1 thru ' .. fixturecount[2] .. ' at 33; store sequence 105 cue 3; Assign sequence 105 cue 3 /loop=2; Assign executor 17 /BrakeingGo=On /MasterGo=Off';
            cmd  = 'go executor 17; go executor 17; go executor 17; go executor 17'; -- Should be in cue 1
            post = 'label DmxSnapshot 173 "ASS_EXEC_11"';
            cleanup ='off executor thru ';
            test_dmx = true;
            test = 173;
            gold = 673;
        },
        -- Testing auto stomp
        --[[{
            pre  = 'Assign sequence 105 cue 3 /loop=None; Assign executor 17 /BrakeingGo=Off /autostomp=On; fixture 1 thru ' .. fixturecount[2]+fixturecount[3] .. '; channel thru; Presettype "Dimmer"; at form "sin"; at effectBPM 60; store Effect 50; ClearAll; assign effect 50 at executor 1.18';
            cmd  = 'go executor 18; go executor 17';
            post = 'label effect 50 "ASS_EXEC_12"; label DmxSnapshot 174 "ASS_EXEC_12"';
            cleanup ='off executor thru ';
            test_dmx = true;
            test = 174;
            gold = 674;
        },]]
        --*******************************************************************************************
        -- Testing priorities
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 100; store sequence 106 cue 1; Assign sequence 106 at executor 18; clearall; Go executor 17;';
            cmd  = 'Assign executor 18 /priority=low; Go executor 18';
            post = 'label DmxSnapshot 175 "ASS_EXEC_13"; label Sequence 106 "ASS_EXEC_13"';
            test_dmx = true;
            test = 175;
            gold = 675;
        },
        {
            cmd  = 'Assign executor 18 /priority=high; Go executor 18; go executor 17';
            post = 'label DmxSnapshot 176 "ASS_EXEC_14"';
            test_dmx = true;
            test = 176;
            gold = 676;
        },
        {
            cmd  = 'Assign executor 18 /priority=htp; Toggle executor 18; Toggle executor 18';
            post = 'label DmxSnapshot 177 "ASS_EXEC_15"';
            test_dmx = true;
            test = 177;
            gold = 677;
        },
        {
            cmd  = 'GoBack executor 17';
            post = 'label DmxSnapshot 178 "ASS_EXEC_16"';
            test_dmx = true;
            test = 178;
            gold = 678;
        },
        {
            cmd  = 'Assign executor 17 /priority=swap; GoBack executor 17';
            post = 'label DmxSnapshot 179 "ASS_EXEC_17"';
            test_dmx = true;
            test = 179;
            gold = 679;
        },
        {
            pre  = 'Assign executor 17 /priority=normal';
            cmd  = 'Assign executor 18 /priority=super; go executor 18; channel 1 thru ' .. fixturecount[1] .. ' at 40';
            post = 'label DmxSnapshot 180 "ASS_EXEC_18"';
            cleanup = 'Assign executor 18 /priority=normal; ClearAll; Off executor thru ';
            test_dmx = true;
            test = 180;
            gold = 680;
        },
        -- Testing soft LTP
        {
            pre  = 'Assign executor 18 /softltp=off';
            cmd  = 'on executor 17; executor 17 at 100; goto executor 17 cue 2; executor 18 at 1';
            post = 'label DmxSnapshot 181 "ASS_EXEC_19"';
            test_dmx = true;
            test = 181;
            gold = 681;
        },
        {
            pre  = 'Assign executor 18 /softltp=on';
            cmd  = 'on executor 17; executor 17 at 100; goto executor 17 cue 2; executor 18 at 1';
            post = 'label DmxSnapshot 182 "ASS_EXEC_20"';
            cleanup = 'executor 18 at 100';
            test_dmx = true;
            test = 182;
            gold = 682;
        },
        {
            post = 'label DmxSnapshot 183 "ASS_EXEC_20_2"';
            blacktest = true;
            test_dmx = true;
            test = 183;
            gold = 683;
        },
        -- Testing playback master
        {
            pre  = 'Assign specialmaster 5.1 at executor 19';
            cmd  = 'Assign executor 18 /PlaybackMaster=Pb1; executor 19 at 50; go executor 18';
            post = 'label DmxSnapshot 184 "ASS_EXEC_21"';
            cleanup = 'Assign executor 18 /PlaybackMaster="Pb None"';
            test_dmx = true;
            test = 184;
            gold = 684;
        },
        -- Testing wrap around
        {
            pre  = 'Assign executor 17 /Wrap=off';
            cmd  = 'go executor 17; go executor 17; go executor 17; go executor 17';
            post = 'label DmxSnapshot 185 "ASS_EXEC_22"';
            cleanup = 'Assign executor 17 /Wrap=on; Off executor thru ';
            test_dmx = true;
            test = 185;
            gold = 685;
        },
        -- Testing restart options
        {
            pre  = 'Assign executor 17 /restart=current';
            cmd  = 'go executor 17; go executor 17; off executor 17; go executor 17';
            post = 'label DmxSnapshot 186 "ASS_EXEC_23"';
            test_dmx = true;
            test = 186;
            gold = 686;
        },
        {
            pre  = 'Assign executor 17 /restart=next';
            cmd  = 'off executor 17; go executor 17';
            post = 'label DmxSnapshot 187 "ASS_EXEC_24"';
            cleanup = 'Assign executor 17 /restart=first; Off executor thru ';
            test_dmx = true;
            test = 187;
            gold = 687;
        },
        -- Testing trigger is go
        {
            pre  = 'Assign executor 17 /triggerisgo=on; Assign sequence 105 cue 1 /trig=time; Assign sequence 105 cue 2 /trig=follow; Assign sequence 105 cue 3 /trig=time';
            cmd  = 'go executor 17; go executor 17; pause executor 17';
            post = ' label DmxSnapshot 188 "ASS_EXEC_25"';
            cleanup = 'Off executor thru; Assign executor 17 /triggerisgo=off; Assign sequence 105 cue 1 /trig=go; Assign sequence 105 cue 2 /trig=go; Assign sequence 105 cue 3 /trig=go';
            test_dmx = true;
            test = 188;
            gold = 688;
        },
        -- Testing cmd disable
        {
            pre  = 'Assign sequence 96 cue 1 /cmd="Fixture 1 at 22.5"; Assign executor 18 /cmddisable=on';
            cmd  = 'go executor 18';
            post = ' label DmxSnapshot 189 "ASS_EXEC_26"';
            cleanup = 'Off executor thru; Assign sequence 96 cue 1 /cmd=""; Assign executor 18 /cmddisable=off';
            test_dmx = true;
            test = 189;
            gold = 689;
        },
        -- Testing playbackfilter
        {
            pre  = 'Channel 1 thru ' .. math.floor(fixturecount[1]/2) .. '; Store world 30 /o; Assign world 30 at executor 18';
            cmd  = 'go executor 18';
            post = ' label DmxSnapshot 190 "ASS_EXEC_27"';
            cleanup = 'Off executor thru; Assign world 1 at executor 18';
            test_dmx = true;
            test = 190;
            gold = 690;
        },
        --*******************************************************************************************
        -- Testing x-fade
        {
            pre  = 'Assign CrossfadeA at executor 17; Assign CrossfadeB at executor 17';
            cmd  = 'Go executor 17; Go executor 17; executor 17 at 30; executor 17 at 60';
            post = 'label DmxSnapshot 191 "ASS_EXEC_28"';
            cleanup ='Off executor thru ';
            test_dmx = true;
            test = 191;
            gold = 691;
        },
        {
            pre  = 'Assign executor 17 /crossfade=on';
            cmd  = 'Go executor 17; Go executor 17; executor 17 at 30; executor 17 at 60';
            post = 'label DmxSnapshot 192 "ASS_EXEC_29"';
            cleanup = 'Off executor thru; Assign Master at executor 17; Assign TempFader at executor 17; Assign executor 17 /crossfade=off';
            test_dmx = true;
            test = 192;
            gold = 692;
        },
        --*******************************************************************************************
        -- Testing Speed - not finished
        --{
        --    pre  = 'Assign executor 17 /speed=mul2';
        --    cmd  = '';
        --    post = 'Off executor thru; label DmxSnapshot 193 "ASS_EXEC_30"';
        --    cleanup = 'Assign executor 17 /speed=normal';
        --    test_dmx = true;
        --    test = 193;
        --    gold = 693;
        --},
        --{
        --    pre  = 'Assign executor 17 /speedmaster=speed1';
        --    cmd  = '';
        --    post = 'Off executor thru; label DmxSnapshot 194 "ASS_EXEC_31"';
        --    cleanup = 'Assign executor 17 /speedmaster=speed_induvidual';
        --    test_dmx = true;
        --    test = 194;
        --    gold = 694;
        --},
        --{
        --    pre  = 'Assign executor 17 /ratemaster=rate1';
        --    cmd  = '';
        --    post = 'Off executor thru; label DmxSnapshot 195 "ASS_EXEC_32"';
        --    cleanup = 'Assign executor 17 /ratemaster=rate_induvidual';
        --    test_dmx = true;
        --    test = 195;
        --    gold = 695;
        --},
        --{
        --    pre  = 'Assign executor 17 /effectspeed=off';
        --    cmd  = '';
        --    post = 'Off executor thru; label DmxSnapshot 195 "ASS_EXEC_33"';
        --    cleanup = 'Assign executor 17 /effectspeed=on';
        --    test_dmx = true;
        --    test = 195;
        --    gold = 695;
        --},
        --*******************************************************************************************
        -- Testing Protect - swop
        {
            pre  = 'Assign executor 18 /swopprotect=on';
            cmd  = 'go executor 18; swop executor 17';
            post = ' label DmxSnapshot 196 "ASS_EXEC_34"';
            cleanup ='swop off executor 17; Off executor thru ';
            test_dmx = true;
            test = 196;
            gold = 696;
        },
        {
            pre  = 'executor 17 at 50';
            cmd  = 'go executor 18; swopon executor 17; swop off executor 17';
            post = 'label DmxSnapshot 197 "ASS_EXEC_35"';
            cleanup='Off executor thru ';
            test_dmx = true;
            test = 197;
            gold = 697;
        },
        {
            pre  = 'go executor 17';
            cmd  = 'swopgo executor 17; swop off executor 17';
            post = ' label DmxSnapshot 198 "ASS_EXEC_36"';
            cleanup = 'Off executor thru; Assign executor 18 /swopprotect=off';
            test_dmx = true;
            test = 198;
            gold = 698;
        },
        -- Testing Kill protect
        {
            pre  = 'Assign executor 18 /killprotect=on';
            cmd  = 'go executor 18; kill executor 18';
            post = ' label DmxSnapshot 199 "ASS_EXEC_37"';
            cleanup = 'Off executor thru; Assign executor 18 /killprotect=off';
            test_dmx = true;
            test = 199;
            gold = 699;
        },
        -- Testing ignore exec time
        {
            pre  = 'Assign executor 17 /ignoreexectime=on; assign specialmaster 2.3 at executor 19';
            cmd  = 'executor 19 at 50; on executor 19; go executor 17';
            cmd_func = function() gma.sleep(1); end;
            post = ' label DmxSnapshot 200 "ASS_EXEC_38"';
            cleanup = 'Off executor 19; Off executor thru; Assign executor 17 /ignoreexectime=off';
            test_dmx = true;
            test = 200;
            gold = 700;
        },
        {
            blacktest = true;
            cmd  = 'on executor 19; go executor 17';
            cmd_func = function() gma.sleep(1); end;
            post = 'executor 19 at 0; Off executor 19; Off executor thru; label DmxSnapshot 201 "ASS_EXEC_39"';
            test_dmx = true;
            test = 201;
            gold = 700;
        },
        -- Testing off on overwritten
        {
            pre  = 'Assign executor 17 /ooo=off; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 75; store sequence 105 cue 1 /o; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 25; store sequence 106 cue 1 /o';
            cmd  = 'go executor 17; go executor 18; off executor 18';
            post = ' label DmxSnapshot 202 "ASS_EXEC_40"';
            cleanup = 'Off executor thru; Assign executor 17 /ooo=on';
            test_dmx = true;
            test = 202;
            gold = 701;
        },
        --*******************************************************************************************
        -- Testing MIB
        {
            pre  = 'store sequence 105 cue 1+2 /o; cd sequences; cd 1; cd 105; assign 2 /MIB=early; cd /; fixture ' .. fixturecount[2]+1 .. ' at 100; attribute TILT 30';
            cmd  = 'store sequence 105 cue 3 /nc; assign executor 17 /MIBAlways=on; executor 17 at 100; go executor 17';
            post = ' label DmxSnapshot 203 "ASS_EXEC_41"';
            cleanup = 'Off executor thru; Assign executor 17 /MIBAlways=off';
            test_dmx = true;
            test = 203;
            gold = 702;
        },
        {
            pre  = 'assign executor 17 /MIBNever=on';
            cmd  = 'go executor 17; go executor 17';
            post = ' label DmxSnapshot 204 "ASS_EXEC_42"';
            cleanup = 'Off executor thru; Assign executor 17 /MIBNever=off';
            test_dmx = true;
            test = 204;
            gold = 703;
        },
        -- Testing auto pre pos
        {
            pre  = 'Fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 75; at attribute COLORRGB1 0';
            cmd  = 'store sequence 106 cue 1 fade 100 /o; Assign sequence 106 executor 17; Assign executor 17 /Prepos=on; go executor 17';
            cmd_func = function() gma.sleep(0.5); end;
            post = ' label DmxSnapshot 205 "ASS_EXEC_43"; label executor 17 "ASS_EXEC_4"';
            cleanup = 'off executor thru; Assign executor 17 /Prepos=off';
            test_dmx = true;
            test = 205;
            gold = 704;
        },
        --*******************************************************************************************
        -- Testing Chaser
        {
            pre  = 'Store sequence 105 cue 2 thru 4 /o; Fixture 1 thru ' .. fixturecount[2]+fixturecount[3] .. ' at 0 thru 100; Store sequence 105 cue 5; cd sequences; cd 1; cd 105; assign 5 /CMD="pause executor 18"; cd /; assign sequence 105 at executor 18; assign executor 18 /chaser=on';
            cmd  = 'go executor 18';
            cmd_func = function() gma.sleep(6); end;
            post = ' label DmxSnapshot 206 "ASS_EXEC_44"';
            cleanup = 'off executor thru; Assign executor 18 /chaser=off';
            test_dmx = true;
            test = 206;
            gold = 705;
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