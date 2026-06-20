-- *******************************************************************
--
-- *******************************************************************

local INVALID_MANET_SLOT = 255;
local MIN_MANET_SLOT     = 0;
local MAX_MANET_SLOT     = 31;

local FIRST_EXEC = 1;
local LAST_EXEC  =99;

local FIRST_PAGE = 1;
local LAST_PAGE  = 99;

-- *******************************************************************
--
-- *******************************************************************

local h_page_progress=nil;
local h_exec_progress=nil;

function MeasurePerformanceLoop()
    gma.cmd("OFF PAGE T");
    h_page_progress=gma.gui.progress.start("PAGE");
    gma.gui.progress.setrange(h_page_progress,FIRST_PAGE,LAST_PAGE);
    for p=FIRST_PAGE,LAST_PAGE do
        gma.gui.progress.set(h_page_progress,p);
        local h_page=gma.show.getobj.handle("PAGE "..p);
        if(h_page) then
            gma.cmd("PAGE "..p);
            local page_name=gma.show.getobj.name(h_page);
            page_name=string.gsub(page_name," ","_");
            local session_data=CreateSessionData(page_name);
            h_exec_progress=gma.gui.progress.start("EXEC");
            gma.gui.progress.setrange(h_exec_progress,FIRST_EXEC,LAST_EXEC);
            for e=FIRST_EXEC,LAST_EXEC do
                gma.gui.progress.set(h_exec_progress,e);
                local handle=gma.show.getobj.handle("EXEC "..e);
                if(handle) then
                    gma.cmd("GO EXEC "..e);
                    local max=MergePerformance(session_data,e);
                    if(max>60) then
                        break;
                    end
                end
            end
            calc_linear_regression_for_summary(session_data.summmary);
            local filename;
            filename=string.format("performance.%s.xml",page_name);
            gma.export(filename,session_data);
            filename=string.format("performance.%s.json",page_name);
            gma.export_json(filename,session_data);
            filename=string.format("performance.%s.csv",page_name);
            gma.export_csv(filename,session_data.summmary);

            gma.gui.progress.stop(h_exec_progress);
            h_exec_progress=nil;
        end
        gma.cmd("OFF PAGE T");
    end
    gma.gui.progress.stop(h_page_progress);
    h_page_progress=nil;
end
-- *******************************************************************
--
-- *******************************************************************

function CreateSessionData(name)
    gma.sleep(4);
    local session=
    {
        build_date =gma.build_date();
        build_time =gma.build_time();
        git_version=gma.git_version();
        summmary   = { name; };
    };
    if(gma.network.getstatus()=="Standalone") then
        local slot_data=gma.network.getmanetslot(INVALID_MANET_SLOT);
        slot_data.performance={ sum= { slot_data.host_name } };
        MergeSlotPerformance(slot_data.performance,INVALID_MANET_SLOT,2);
        session[INVALID_MANET_SLOT]=slot_data;
        session.summmary[#session.summmary+1]=slot_data.performance.sum;
    else
        for slot_index=MIN_MANET_SLOT,MAX_MANET_SLOT do
            local slot_data=gma.network.getmanetslot(slot_index);
            if(slot_data) then
                slot_data.performance={ sum= {  slot_data.host_name } };
                MergeSlotPerformance(slot_data.performance,slot_index,2);
                session[slot_index]=slot_data;
                session.summmary[#session.summmary+1]=slot_data.performance.sum;
            end
        end
    end
    return session;
end

-- *******************************************************************
--
-- *******************************************************************

local SLOT_INDEX={ 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,255 };

function MergePerformance(session_data,e)
    gma.sleep(2);
    local max=0;
    for i,slot_index in ipairs(SLOT_INDEX) do
        local slot_data=session_data[slot_index];
        if(slot_data and slot_data.parameter_count>=1024) then
            local v=MergeSlotPerformance(slot_data.performance,slot_index,e+2);
            if(v>max) then max=v; end
        end
    end
    return max;
end

-- *******************************************************************
--
-- *******************************************************************

function MergeSlotPerformance(performance,slot_index,e)
    local raw_performance=gma.network.getperformance(slot_index);
    if(performance and raw_performance) then
        local j=1;
        local performance_sum=0;
        local n=#raw_performance;
        for i=1,n,2 do
            local name =raw_performance[i];
            local value=raw_performance[i+1];
            local entry=performance[j];
            if(entry==nil) then
                performance[j]={ name,value };
            else
               entry[#entry+1]=value;
            end
            if(string.find(name,"Wait")==nil) then
                performance_sum=performance_sum+value;
            end
            j=j+1;
        end
        performance.sum[e]=performance_sum;
        gma.echo("MergeSlotPerformance slot=",slot_index," e=",e," sum=",performance_sum);
        return performance_sum;
    else
        if(performance==nil) then gma.echo("MergeSlotPerformance performance=nil"); end
        if(raw_performance==nil) then gma.echo("MergeSlotPerformance raw_performance=nil"); end
    end
end

-- *******************************************************************
--
-- *******************************************************************

function calc_linear_regression_for_summary(summary)
    for i=2,#summary do
        local performance=summary[i];
        local x={};
        local y={};
        for j=2,#performance do
            local k=j-1;
            x[k]=j-2;
            y[k]=performance[j];
        end
        local m,b=calc_linear_regression(x,y);
        table.insert(performance,1,m);
    end
end

function calc_linear_regression(x,y)
    local n=#x;
    if(n>0) then
        local sum_x =0;
        local sum_y =0;
        local sum_xy=0;
        local sum_xx=0;
        for i=1,n do
            -- gma.echo("X=",x[i]," Y=",y[i]);
            sum_x  = sum_x  + x[i];
            sum_y  = sum_y  + y[i];
            sum_xy = sum_xy + x[i]*y[i];
            sum_xx = sum_xx + x[i]*x[i];
        end
        local m = (sum_xy - sum_x * sum_y / n) / ( sum_xx - sum_x * sum_x /n );
        local b = (sum_y - m * sum_x ) / n;
        return m,b;
     end
end

-- *******************************************************************
--
-- *******************************************************************

function Cleanup()
    gma.gui.progress.stop(h_page_progress);
    gma.gui.progress.stop(h_exec_progress);
    gma.cmd("OFF PAGE T");
end

-- *******************************************************************
--
-- *******************************************************************

return MeasurePerformanceLoop,Cleanup;