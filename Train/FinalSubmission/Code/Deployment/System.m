classdef System < handle
    %    System class
    %    The whole schedule system, including the controller and the user
    %    interface
    
    properties
        hController
        hDisplay
        time
        t
    end
    
    methods
        function obj = System(inputPath)
            %    System constructor
            obj.hController = Controller(inputPath);
            obj.hController.hSystem = obj;
            obj.hDisplay = Display;
            obj.hDisplay.hController = obj.hController;
            obj.hDisplay.hSystem = obj;
            obj.hDisplay.hEnvironment = obj.hController.hEnvironment;
            obj.t = timer;
            obj.t.ExecutionMode='fixedSpacing';
            obj.t.Period=0.1;
            obj.t.TimerFcn=@obj.updateState;
%             obj.t.BusyMode = 'queue';
            obj.time = -0.1;

        end
        
        %    T1.4.1
        function updateState(obj, ~, ~)
            %    Update the state of environment and display
            obj.time = obj.time + obj.t.Period;
            allFinish = obj.hController.updateState(obj.time, obj.t.Period);
            obj.hDisplay.updateState;
            if allFinish == 1
                %    Branch - Tcover 1.4.1.1
                obj.stopSimulate();
            end
        end
        
        %    T11.4.2
        function beginSimulate(obj)
            %    Begin simulate
            start(obj.t);
            %    Statement - Tcover 1.4.2.1
        end
        
        %    T1.4.3
        function stopSimulate(obj)
            %    Begin simulate
            stop(obj.t);
            %    Statement - Tcover 1.4.3.1
        end
    end
end

