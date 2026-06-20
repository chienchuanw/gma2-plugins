--*******************************************************************************************
-- This script tests the method to insert a page.
-- Page 97-99, 197-205, Seq 201+202
--*******************************************************************************************

local test=
{
    method_name     = "INSERT";
    object_name     = "PAGE";
    pre             = 'ClearAll; delete page 97 thru 99 /nc; store page 97 thru 99';
    steps =
    {
        {
            -- Create Page 99, insert at Page 98 which is occupied
            pre  = 'Page 99; Channel thru full; Store Seq 201 /o; Assign Seq 201 at Exec 99.1; Page 98; Channel thru at 42; Store Seq 202 /o; Assign Seq 202 at Exec 98.1; clearall';
            cmd  = 'Insert Page 99 at 98';
            post = 'Label Seq 201 "INS_PAG_1.1"; Label Seq 202 "INS_PAG_1.2"; Label Page 99 "INS_PAG_1.1"; Label Page 98 "INS_PAG_1.2";';
            test = {98,99};
            gold = {198,199}; -- Seq 202 at Page 99, Seq 201 at Page 98
        },
        {
            -- Insert Page 98 and 99 at Page 97
            pre  = '';
            cmd  = 'Insert Page 98 + 99 at 97';
            post = 'Label Page 97 "INS_PAG_2.1"; Label Page 98 "INS_PAG_2.2";';
            test = {97,98,99};
            gold = {200,201,202};
        },
        {
            -- Insert Page 97 at 98 (afterwards page 97 should be free)
            pre  = '';
            cmd  = 'Insert Page 97 at 98';
            post = 'Label Page 98 "INS_PAG_3.1"; Label Page 99 "INS_PAG_3.2"; page 1';
            cleanup = '';
            test = {97,98,99};
            gold = {203,204,205};
        },
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