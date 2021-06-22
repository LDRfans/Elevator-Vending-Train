classdef MaintainSys < handle
    %MAINTAINSYS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        offlinePanel
        onlinePanel
        vending
        logSys
    end
    
    methods
        function obj = MaintainSys()
            obj.offlinePanel = OfflineMaintainPanel();
            obj.onlinePanel = OnlinePanel();
            obj.logSys = LogSys();
            obj.logSys.onlinePanel = obj.onlinePanel;
        end
        
        function flag = fixUserProblem(obj)
            % statement T cover 1.5.1.1
            flag = 1;
        end
    end
end

