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
            obj.currentTrain = "None";
        end
    end
end

