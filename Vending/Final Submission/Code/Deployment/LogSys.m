classdef LogSys < handle
    %PURCHASELOG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        currentLog
        onlinePanel
    end
    
    methods
        function obj = LogSys()
            obj.currentLog = -1;
            % initialize log panel - done in maintainSys now
        end
        
        function addOneRecord(obj, record)
            if obj.currentLog == -1
                % branch T cover 1.3.1.1
                obj.currentLog = record;
            else
                % branch T cover 1.3.1.2
                obj.currentLog = [obj.currentLog;record];
            end
        end
        
        function saveCurrentLog2Excel(obj, filename)
            % statement T cover 1.3.2.1
            title = ["Time Stamp" "Product ID" "Product Price" "Input Money" "Remain Change" "Get Product"];
            data = obj.currentLog;
            xlswrite(filename, [title; data]);
            obj.currentLog = -1;
            obj.onlinePanel.UITable.Data = [];
        end
        
        function refreshOnlinePanel(obj)
            % statement T cover 1.3.1.3
            obj.onlinePanel.UITable.Data = obj.currentLog;
        end
    end
end

