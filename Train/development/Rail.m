classdef Rail < handle
    %    Rail class
    %    The rail in the station for the train stopping
    
    properties        
        %%%%  Rail Information  %%%%
        mainInFlag
        mainOutFlag
        %%%%  Rail Information  %%%%
        
        %%%%  State Information  %%%%
        currentTrainName
        %%%%  State Information  %%%%
    end
    
    methods
        function obj = Rail(mainInFlag, mainOutFlag)
            %    Rail constructor
            obj.mainInFlag = mainInFlag;
            obj.mainOutFlag = mainOutFlag;
            obj.currentTrainName = "None";
        end
    end
end

