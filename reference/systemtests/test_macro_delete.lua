--*******************************************************************************************
-- This script tests the methods to delete a macro. 
-- Macro a.b.c is page a. macro b. line c
-- Macro 8+10
--*******************************************************************************************

local test =
{
    method_name      = "DELETE";
    object_name      = "MACRO";
    pre              = 'ClearAll; delete macro 8 + 9 /nc';
    steps =
    {
        {
            pre  = 'store macro 1.8 ; store macro 1.8.1; assign macro 1.8.1 /cmd="delete plug thru" /info="Loescht alle Plugins"; store macro 1.8.2; assign macro 1.8.2 /cmd="ClearAll" /info="Clear"';
            cmd  = 'delete macro 1.8.2 /nc';  -- SuperPreset.Macro.Zeile    --deleting one line
            post= 'label macro 8 "DEL_MACR_1"';
            test = 8;  
            gold = 108;
        },
        {
            pre  = 'store macro 1.9 ; store macro 1.9.1; assign macro 1.9.1 /cmd="delete plug thru" /info="Loescht alle Plugins"; store macro 1.9.2; assign macro 1.9.2 /cmd="ClearAll" /info="Clear"';
            cmd  = 'delete macro 1.9 /nc';
            test = 9;
            gold = -1;
        },
        {
            pre  = 'store macro 1.10 ; store macro 1.10.1; assign macro 1.10.1 /cmd="delete plug thru" /info="Loescht alle Plugins"; store macro 1.10.2; assign macro 1.10.2 /cmd="ClearAll" /info="Clear"; label macro 1.10 "Wird gelöscht"';
            cmd  = 'delete macro "Wird gelöscht" /nc'; --deleting by label
            cleanup= 'off macro thru';
            test = 10;
            gold = -1;
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