--*******************************************************************************************
-- This Plugin creates the files for the lua-testmatrix import tests
--*******************************************************************************************

local C = function(command)
    local cmd_result = gma.cmd(command);
    if(cmd_result) then
        gma.feedback("CMD-Error:"..cmd_result);
    end
end
local F = gma.feedback;
local E = gma.echo;
local fixturecount = {2000,2000,2000,2000};    -- default values
local result = false;

function createFiles()
    yield2 = true;
    fixturecount = get_prop_fixturecount();
    F("File-Generator v1.0");
    if server == true then
        result = true;
    else
        if host_version == "3.1.2.5" then
            result = true;
        else
            --result = gma.gui.confirm("Proceed?","Do you want to create the files?|This will manipulate your showfile.");
            result = true;
        end
    end
    if(result) then
        F("Creating testmatrix import Files");
        C('fixture thru; channel thru ');
        if compare_versions(host_version,"3.1.0.0") then
            amount = gma.show.getvar("SELECTEDFIXTURESCOUNT");
        else
            F("Can't get fixture Count... Version incompatible.");
            amount = 1;
        end
        F("Patched devices: " .. amount);
        if tonumber(amount) == 0 then
            local result = false;
            if server == true then
                result = true;
            else
                if host_version == "3.1.2.5" then
                    result = false;
                else
                    result = gma.gui.confirm("Initalize Showfile","There are no devices patched. Should your showfile be initialzed?");
                end
            end
            if result then
                yield = true;
                C('Plugin ShowfileInit');
                local mytime = math.floor(gma.gettime());
                while yield do
                    local delta = gma.gettime() - mytime;
                    if delta > 2 then
                        gma.echo("Waiting");
                        mytime = gma.gettime();
                    end
                end
                gma.cmd('fixture thru; channel thru ');
                amount = gma.show.getvar("SELECTEDFIXTURESCOUNT");
            else
                F('There are no devices patched. Test will be skipped!');
                if not host_version == "3.1.2.5" then
                    if compare_versions(host_version,"3.1.3.0") then
                        gma.gui.msgbox("Test-Script","There are no fixtures created to test with!");
                    else
                        gma.gui.confirm("Test-Script","There are no fixtures created to test with!");
                    end
                end
            end
        end
        if(tonumber(amount) > 0) then
            -- Prepare
            C('cd /; ClearAll;');
            
            -- Cue file
            F("Creating cue file.");
            C('delete sequence 280 /nc');
            C('fixture 1 thru ' .. fixturecount[2] .. ' at 50; store sequence 280 cue 1 /use=active /nc; assign sequence 280 cue 1 fade 5');
            C('export sequence 280 cue 1 "import-cue.xml" /nc; label sequence 280 "Auto Gen"');
            C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');
            
            -- Effect file
            F("Creating effect file.");
            C('delete effect 300 /nc');
            C('store effect 300 /Mode=Abs /nc; assign presettype "DIMMER" at effect 300');
            C('Export Effect 300 "import-effect.xml" /nc; label effect 300 "Auto Gen"');
            C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');
            
            -- Executor file
            F("Creating executor file.");
            C('delete executor 200 /nc');
            C('assign specialmaster 2.1 at executor 200');
            C('Export executor 200 "import-executor.xml" /nc');
            C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');
            
            -- Feature file
            F("Creating feature file.");
            --C('delete feature colorrgb /nc');
            C('fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 100; feature colorrgb at 40');
            C('Export Feature colorrgb "import-feature-colorrgb.xml" /nc');
            C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');

           -- Group file
            F("Creating group file.");
            C('delete group 99 /nc');
            C('Fixture ' .. math.floor(fixturecount[2]/3) .. ' thru ' .. fixturecount[2] .. ' + ' .. fixturecount[2]+math.floor(fixturecount[2]/4) .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; store Group 99 /nc');
            C('Export group 99 "import-group.xml" /nc; label group 99 "Auto Gen"');
            C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');
            
            -- Layout file
            F("Creating Layout file.");
            C('delete layout 200 /nc');
            C('Fixture ' .. math.floor(fixturecount[2]/4) .. ' thru ' .. fixturecount[2] .. '; store Layout 200');
            C('Export Layout 200 "import-layout.xml" /nc; label Layout 200 "Auto Gen"');
            C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');

            -- Macro file
            F("Creating macro file.");
            C('delete macro 5 /nc');
            C('store macro 1.5; store macro 1.5.1; assign macro 1.5.1 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 81"; assign macro 1.5.1 /info="Macro prepared for import/export"; store macro 1.5.2; assign macro 1.5.2 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 50"; clearall');
            C('Export Macro 5 "import-macro.xml" /nc; label macro 5 "Auto Gen"');
            C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');
            
            -- Mask file
            F("Creating mask file.");
            C('Export Mask 10 "import-mask.xml" /nc; label mask 10 "Auto Gen"');  
            C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');

            -- Page File
            F("Creating page file.");
            C('delete page 91 /nc; store page 91 /nc');
            C('channel thru at 42; store seq 142 /o; page 91; assign seq 142 at exec 91.104; clearall;');
            C('label page 91 "Auto Gen"; label seq 142 "Auto Gen"; label exec 91.104 "Auto Gen"');
            C('export page 91 "import-page.xml" /nc');
            C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');
            
            -- Plugin file
            F("Creating plugin file.");
            C('delete plugin 514 /nc');
            C('store plugin 514; label plugin 514 "generated"');
            C('Export Plugin 514 "import-plugin.xml" /nc');   --plugin stored in folder plugin
            C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');
            
            -- Preset file
            F("Creating preset file.");
            C('delete preset 1.30 /nc');
            C('Channel 1 thru 100 at 89; store preset 1.30');
            C('Export preset 1.30 "import-preset.xml" /nc; label preset 1.30 "Auto Gen"');
            C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');
            
            -- Screen file
            F("Creating screen file.");
            C('delete screen 3 /nc');
            C('cd screen 3; store 1 /SCREEN=3; Assign 1 /display=2 /type="clock" /width=16 /height=4; store 2 /SCREEN=3; Assign 2 /display=2 /type="channel" /posx=0 /posy=4 /width=16 /height=4;');
            C('Export screen 3 "import-screen.xml" /nc; view 1');
            C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');

             -- Sequence file
            F("Creating sequence file.");
            C('delete sequence 283 /nc');
            C('Channel 1 thru at 89; store sequence 283 /nc');
            C('Export Sequence 283 "import-sequence.xml" /nc; label sequence 283 "Auto Gen"');
            C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');
            
            -- Timecode file
            F("Creating timecode file.");
            C('delete tc 24 /nc');
            C('store tc 24 /nc; label tc 24 "Auto Gen"');
            C('Export tc 24 "import-timecode.xml" /nc');
            C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');

            -- Userprofile file
            F("Creating userprofile file.");
            C('delete userprofile thru /nc');
            C('store userprofile 2 "Auto Gen"; assign userprofile 2 /info="auto gen"');
            C('Export userprofile 2 "import-userprofile.xml" /nc');
            C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');

            -- View file
            F("Creating view file.");
            C('delete view 24 /nc');
            C('cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="Stage" /width=16 /height=8; store view 24 /SCREEN=2');
            C('Export view 24 "import-view.xml" /nc; label view 24 "Auto Gen"; view 1');
            C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');

            -- Viewbutton file
            F("Creating viewbutton file.");
            C('viewpage 2');
            C('cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="Help" /width=13 /height=5 /posx=1 /posy=1; store viewbutton 4 /screen=2;');
            C('Export viewbutton 4 "import-viewbutton.xml" /nc; label viewbutton 4 "Auto Gen"; viewpage 1; view 1');
            C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');

            -- Viewpage file
            F("Creating viewpage file.");
            C('viewpage 8');
            C('cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="plugins" /width=10 /height=3 /posx=2 /posy=2; store view 28 /SCREEN=2; assign view 28 at viewbutton 1');
            C('Export viewpage 8 "import-viewpage.xml" /nc; label view 28 "Auto Gen"; viewpage 1; view 1');
            C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');

            -- World file
            F("Creating world file.");
            C('delete world 2 /nc');
            C('Fixture ' .. math.floor(fixturecount[2]/3) .. ' thru ' .. fixturecount[2] .. ' + ' .. fixturecount[2]+math.floor(fixturecount[2]/4) .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; store world 2');
            C('Export world 2 "import-world.xml" /nc; label world 2 "Auto Gen"; world 1');
            C('cd /; world 1; off page thru; off dmxuniverse thru; resetdmxselection; unpark dmxuniverse thru; off sequence thru');
            
            F("All files are created.");
            F("Have fun.");
        else
            F("There are no fixtures patched!");
        end
    end
    yield2 = false;
end

return createFiles;