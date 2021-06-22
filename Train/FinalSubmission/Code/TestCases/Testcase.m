classdef Testcase < matlab.uitest.TestCase
    %    Testcase class
    
    properties
        system
        controller
        environment
        display
    end
    
    methods
        function obj = Testcase(inputPath)
            %    Testcase constructor
            obj.system = System(inputPath);
            obj.controller = obj.system.hController;
            obj.environment = obj.controller.hEnvironment;
            obj.display = obj.system.hDisplay;
        end
    end
end

