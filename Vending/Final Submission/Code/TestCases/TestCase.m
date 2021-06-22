classdef TestCase < matlab.uitest.TestCase
    %    Testcase class
    
    properties
        vending
        userapp
        offlineapp
        onlineapp
    end
    
    methods
        function obj = TestCase()
            %    Testcase constructor
            obj.vending = Vending(1,0.0);
            obj.userapp = obj.vending.userPanel;
            obj.offlineapp = obj.vending.maintainSys.offlinePanel;
            obj.onlineapp = obj.vending.maintainSys.onlinePanel;
        end
    end
end


