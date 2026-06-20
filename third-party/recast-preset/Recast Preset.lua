--[[ 
    MA2 Recast Preset
    version 1.9.1
    Last update May 5, 2024
    Developed by Jeremy Dufeux - Carrot Industries
    https://carrot-industries.com
    contact: contact@carrot-industries.com

    The entire content and modifications of this code are protected under copyright by Carrot Industries. 
    They cannot be utilized, either in whole or in part, without obtaining written permission from Jérémy Dufeux and acknowledging the source. 
    This plugin is exclusively authorized for use by individuals who have acquired it directly from carrot-industries.com . 
    Please show respect by refraining from unauthorized use and by appropriately attributing the work to its creators.
    
    The use and modification of this plugin is at your own risk, be sure to do all backups you need before use it.
    Carrot Industries declines all responsibility in the event of loss of data, system failures, or any other harm that may result from the use of the plugin
    We will not be held responsible for any direct or indirect consequences related to the use of our plugins.

    How to do: 
        - Make a backup
        - Run the plugin
        - if you didn't change de config bellow:
            - The plugin will ask you to leave the session, if you confirm on the popup the plugin will leave the session
            - The plugin will ask you to use only the selected fixtures if you did one, else it will use all available fixture in the preset
            - It will also ask you if you want to recast in cue only mode or not

    Note that: 
        - The plugin can take a while to execute depending on your sequences amount
        - After the plugin finished, it will select world 1 if you used it with a selection
]]

local config = {}

-- Show Backup Popup:
-- true: The plugin will always warm you to make a backup before start recast
-- false: The plugin doesn't show the popup
config.showBackupPopup = true   -- true or false

-- Use selection mode:
-- nil: if you didn't select fixture it will rescast preset for all available fixtures
--      if you select fixture before start the plugin, it will ask you to use the selection or not
-- true: will always use selected fixture to perfom the recast, 
--       if you don't have selection, the plugin doesn't recast anything
-- false: will always use all available fixture for the preset, wathever you have a selection or not
config.useSelection = nil   -- nil, true or false

-- Cue Only mode:
-- nil: will ask you the mode when you start the plugin
-- true: to use cue only mode, so the values will not be tracked if original values are absent
-- false: to not use cue only mode, so the values will be tracked
config.cueOnly = nil        -- nil, true or false

-- Unlock sequences:
-- true: All sequences will be unlocked
-- false: The plugin do not recast in locked sequences
config.unlock = true        -- true or false

-- TelnetTimeout:
-- Increase this value if the plugin seems to work not properly, it varies from one show to another.
-- You can try to decrease the value if the recast is doing well in your show and you whant to speed it up 
config.telnetTimeout = 0.5

-- Credentials:
-- You can change the user and password to perfom the recast on a different user profile, to use a limited scope for the recast
config.user = "administrator"
config.password = "admin"





---------------------------------------- Don't edit below this line ----------------------------------------

local a=gma.echo;local b=gma.feedback;local c=gma.cmd;local d=gma.show;local e=gma.gui;local f=e.progress;local g=d.getobj;local h=d.property;local i=gma.sleep;local j="Debug"local k="Produktion"local l=nil;local m=nil;local n=true;local o;local p="CI"local q="RP"local r="42"local s="BUOYLQVATM"local t="Plugin not enabled"local u="Please follow the instructions in readme.txt provided in plugin zip to enable it.\nIf you didn't pursharsed this plugin you don't have right to use it,\nplease go to carrot-industries.com to buy it and support my work."local v="Please confirm"local w="Please confirm before launch the plugin,\nbe sure to backup your show before!"local x=false;function CI_RP_A()b("********************** Recast Preset **********************")b("")c(j..''..k)local y;local z;local A;local B=d.getvar(p..''..q)local C=false;if B~=p..''..s..''..q..''..r then e.msgbox(t,u)goto D end;if config.showBackupPopup then A=e.confirm(v,w)else A=true end;if A then c('Assign Root 3.1 /Telnet="Login Enabled"')local E=require("socket/socket")local F,G="127.0.0.1",30000;local H=E.connect(F,G)H:settimeout(config.telnetTimeout)local I=tonumber(d.getvar("selectedfixturescount"))l=config.useSelection;local J=d.getvar("HostStatus")if J~="Standalone"then local K=e.confirm("Session is active","The recast must be done outside of a network session\n\nEnd the session?")if K then c('EndSession /nc')C=true else goto D end end;if l==nil then if I~=0 then local K=e.confirm("Use selection","Use current selection for recast?")if K~=nil then l=true else l=false end else l=false end end;if l==true and I==0 then e.msgbox("No fixtures selected","Please select fixture first")goto D end;if config.cueOnly==nil then m=e.confirm("Cue only Mode?","Recast preset in cue only?")end::L::local y,M=CI_RP_H("Enter preset number to recast :","x.y")if M then goto D end;b("User input : "..y)local N=CI_RP_N(y)if N==nil then local A=e.confirm("Syntax error","There was an syntax error in your input")if A then goto L else goto D end end;z=CI_RP_W(N)if CI_RP_M(z)==0 then e.confirm("No preset found","No preset found for given input")goto D end;local O=""for P,Q in pairs(z)do O=O.." "..Q..","end;O=string.sub(O,1,-2)b("Preset to recast :"..O)if CI_RP_C(H,config.user,config.password)then local R=CI_RP_J(1000)if l==true then c('Store World '..R)CI_RP_B(H,'World '..R)end;if config.unlock==true then CI_RP_B(H,'Unlock Sequence 1 Thru')end;local S=0;for P,Q in pairs(z)do if string.match(Q,"^%d+%.%d+$")then S=S+CI_RP_D(H,R,Q)end end;if C then local T=e.confirm("Recast finished","The recast updated "..S.." cues\n\nRestart Session?")if T then c('JoinSession')C=false end else e.msgbox("Recast finished","The recast updated "..S.." cues")end;if l==true then CI_RP_B(H,'World 1')CI_RP_B(H,'Delete World '..R)end;CI_RP_B(H,'logout')i(config.telnetTimeout)H:close()end end::D::if C then local T=e.confirm("Restart the session","The plugin ended\n\nRestart Session?")if T then c('JoinSession')end end;x=true;c(j..''..k)end;function CI_RP_B(H,U)H:send(U..'\r')end;function CI_RP_C(H,V,W)while true do local X,P,P=H:receive()if X==nil then goto Y end;if CI_RP_I(X,"Please login !")then CI_RP_B(H,'Login "'..V..'" "'..W..'"')end;if CI_RP_I(X,"Logged")and CI_RP_I(X,V)then b("Logged!")return true end end::Y::return false end;function CI_RP_D(H,R,Z)CI_RP_B(H,'Selfix Preset '..Z)CI_RP_B(H,'At Preset '..Z)local _=CI_RP_J(1000)CI_RP_B(H,'Store World '.._)CI_RP_B(H,'ClearAll')CI_RP_B(H,'World '.._)local a0=CI_RP_E(H,Z)local a1=CI_RP_M(a0)local S=0;for a2,a3 in pairs(a0)do if n then if a2==1 then o=f.start("Recast preset "..Z)f.setrange(o,1,a1)else f.set(o,a2)f.settext(o,"in Sequence "..a3)end end;if m then CI_RP_B(H,'Block Sequence '..a3)end;local a4=CI_RP_F(H,Z,a3)for P,a5 in pairs(a4)do CI_RP_G(H,Z,a3,a5)S=S+1 end;if m then CI_RP_B(H,'Unblock Sequence '..a3)end;if a2==a1 and n then f.stop(o)end end;if l then CI_RP_B(H,'World '..R)else CI_RP_B(H,'World 1')end;CI_RP_B(H,'Delete World '.._)return S end;function CI_RP_E(H,Z)CI_RP_B(H,'Search Preset '..Z)local a6={}local a7={}while true do local X,P,P=H:receive()if X==nil then goto Y end;if CI_RP_I(X,"parameters in Sequ")then local a8=tonumber(string.match(X,"Sequ%s*(%d+)"))CI_RP_K(a6,a7,a8)end end::Y::return a6 end;function CI_RP_F(H,Z,a8)CI_RP_B(H,'Search Preset '..Z..' If Sequence '..a8)local a9={}local a7={}while true do local X,P,P=H:receive()if X==nil then goto Y end;if CI_RP_I(X,"parameters in Sequ")then local aa=tonumber(string.match(X,"Cue%s+(%d+)"))CI_RP_K(a9,a7,aa)end end::Y::return a9 end;function CI_RP_G(H,Z,a8,aa)b('Recast preset '..Z..' in Sequence '..a8 ..' cue '..aa)CI_RP_B(H,'Search Preset '..Z..' If Sequence '..a8 ..' cue '..aa)while true do local X,P,P=H:receive()if X==nil then goto Y end end::Y::CI_RP_B(H,'SelFix SearchResult')CI_RP_B(H,'At Preset '..Z)if m then CI_RP_B(H,'Store Sequence '..a8 ..' cue '..aa..' /m /co /nc')else CI_RP_B(H,'Store Sequence '..a8 ..' cue '..aa..' /m /nc')end;CI_RP_B(H,'ClearAll')end;function CI_RP_H(ab,ac)local ad;while true do ad=gma.textinput(ab,ac)if not ad or#ad==0 or ad==ac then local ae=e.confirm("No input provided","Continue the plugin?")if not ae then return nil,true end else return ad end end end;function CI_RP_I(af,ag)if af and ag then if string.find(af,ag,1,true)then return true end end;return false end;function CI_RP_J(ah)local ai=0;if ah~=nil then ai=ai+ah end::L::ai=ai+1;local aj=g.handle('World '..ai..'')if aj then goto L else return ai end end;function CI_RP_K(ak,al,am)if CI_RP_L(al,am)then al[am]=true;table.insert(ak,am)end end;function CI_RP_L(al,am)return al[am]==nil end;function CI_RP_M(an)local ao=0;for P in pairs(an)do ao=ao+1 end;return ao end;function CI_RP_N(ap)local aq=CI_RP_O(ap)if CI_RP_P(aq[1])then local ar={}local as,at;as,at=CI_RP_Q(aq[1])table.insert(ar,as.."."..at)table.remove(aq,1)local au='ThruAddMinus'local av='Add'for P,aw in ipairs(aq)do if CI_RP_R(aw)then if au=='ThruAddMinus'then au='LastPreset'else goto ax end elseif aw=="+"then if au=='ThruAddMinus'or au=='AddMinus'then au='AddFirstPreset'av='Add'end elseif aw=="-"then if au=='ThruAddMinus'or au=='AddMinus'then au='MinusFirstPreset'av='Minus'end elseif CI_RP_S(aw)or CI_RP_P(aw)then if au=='LastPreset'then local ay,az=CI_RP_V(aw)if az~=nil then if az~=as then goto ax end end;if av=='Add'then for aA=at+1,ay,1 do if CI_RP_U(ar,as.."."..aA)then table.insert(ar,as.."."..aA)end end elseif av=='Minus'then for aB=at,ay,1 do for a2,Q in ipairs(ar)do if Q==as.."."..aB then table.remove(ar,a2)end end end end;au='AddMinus'elseif au=='AddFirstPreset'then local Q,az=CI_RP_V(aw)if az~=nil then as=az end;at=Q;if CI_RP_U(ar,as.."."..Q)then table.insert(ar,as.."."..Q)end;au='ThruAddMinus'elseif au=='MinusFirstPreset'then local Q,az=CI_RP_V(aw)if az~=nil then as=az end;at=Q;for aC,aD in ipairs(ar)do if aD==as.."."..Q then table.remove(ar,aC)end end;au='ThruAddMinus'else goto ax end else goto ax end end;return ar end::ax::return nil,nil end;function CI_RP_O(ap)local aE={}for aF in ap:gmatch("%S+")do table.insert(aE,aF)end;return aE end;function CI_RP_P(ap)local aG="%d+%.%d+"return string.match(ap,aG)~=nil end;function CI_RP_Q(ap)local az,aH=string.match(ap,"(%d+)%.(%d+)")return tonumber(az),tonumber(aH)end;function CI_RP_R(ap)local aI=string.lower(ap)local aJ={"thru","thr","th","t"}for aC,aH in ipairs(aJ)do if aI==aH then return true end end;return false end;function CI_RP_S(ap)local aK=tonumber(ap)if aK then return math.floor(aK)==aK else return false end end;function CI_RP_T(aL,aM)if#aL~=#aM then return false end;for aC=1,#aL do if aL[aC]~=aM[aC]then return false end end;return true end;function CI_RP_U(table,aH)for aC=1,#table do if table[aC]==aH then return false end end;return true end;function CI_RP_V(ap)local az,Q;if CI_RP_S(ap)then Q=tonumber(ap)elseif CI_RP_P(ap)then az,Q=CI_RP_Q(ap)end;return Q,az end;function CI_RP_W(z)local aN={}for P,Q in pairs(z)do table.insert(aN,Q)end;for P,Q in pairs(z)do local aj=g.handle('Preset '..Q)if not aj then for aO,aP in pairs(aN)do if Q==aP then table.remove(aN,aO)end end end end;return aN end;function CI_RP_X()if not x then f.stop(o)c(j..''..k)e.confirm("The plugin did not work properly","The plugin crashed, see System Monitor for details.")end end;return CI_RP_A,CI_RP_X
