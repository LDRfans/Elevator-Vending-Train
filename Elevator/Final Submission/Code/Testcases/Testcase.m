classdef Testcase < matlab.uitest.TestCase
    
    properties
        hSystemController
        hElevators
        hFloorUI
        hCarUIs
    end
    
    methods
        function obj = Testcase()
            obj.hSystemController = SystemController();
            obj.hElevators = obj.hSystemController.hElevators;
            obj.hFloorUI = obj.hSystemController.hFloorUI;
            obj.hCarUIs = [obj.hElevators(1).hCarUI, obj.hElevators(2).hCarUI];
        end
    end
    
end