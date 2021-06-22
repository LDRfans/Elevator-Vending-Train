classdef Railway < handle
    %    Railway class
    %    The rail between two stations, including the start station and the
    %    end station
    
    properties
        %%%%  Railway Information  %%%%
        startStation
        endStation
        length
        %%%%  Railway Information  %%%%
        
        %%%%  State Information  %%%%
        currentTrain
        %%%%  State Information  %%%%
    end
    
    methods
        function obj = Railway(startStation, endStation, length)
            %    Railway constructor   
            obj.startStation = startStation;
            obj.endStation = endStation;
            obj.length = length;
            obj.currentTrain = 0;
        end
        
        function railwayInfo = displayRailwayInfo(obj)
            %    Display the information of railway
            railwayInfo = {obj.startStation, obj.endStation, obj.length, obj.currentTrain};
        end
    end
end

