classdef SystemController < handle
    properties
        hElevators
        hActivityMonitor
        hFloorUI
        
        t
    end

    methods
        function obj=SystemController()
        % Init everything
            % Create Elavators
            obj.hElevators = [Elevator("Elevator 1",1,[1,3],1000), Elevator("Elevator 2",1,[0,3],1000)];
            obj.hElevators(1).hSystemController = obj;
            obj.hElevators(2).hSystemController = obj;
            
            % Build system
            obj.hActivityMonitor = ActivityMonitor;     % monitor 2 elevators
            obj.hFloorUI = [FloorUI, FloorUI, FloorUI, FloorUI];    % 4 floors
            
            % Set ActivityMonitor
            obj.hActivityMonitor.hElevators = obj.hElevators;
            obj.hActivityMonitor.hSystemController = obj;
            
            % Set FloorUI
            for i = 1:4
                obj.hFloorUI(i).floor = i-1;
                obj.hFloorUI(i).hElevators = obj.hElevators;
                obj.hFloorUI(i).hSystemController = obj;
                obj.hFloorUI(i).init;
            end
            
            % Set timer
            obj.t = timer;
            obj.t.ExecutionMode='fixedRate';
            obj.t.Period=1;
            obj.t.TimerFcn=@obj.updateState;
            start(obj.t);
            
        end
        
        function [elevator_hierarchy] = buildHierarchy(obj, floor_calling, direction_calling)
            elevator_hierarchy = [0,0];
            % Build hierarchy
            for i = 1:2
                if obj.hElevators(i).moving_direction == 1 || obj.hElevators(i).direction_store == 1    % Branch - Tcover1.1.1.1
                    if floor_calling > obj.hElevators(i).height    % Branch - Tcover1.1.1.2
                        if direction_calling == "up"    % Branch - Tcover1.1.1.3
                            elevator_hierarchy(i) = 1;
                        elseif direction_calling == "down"    % Branch - Tcover1.1.1.4
                            elevator_hierarchy(i) = 2;
                        end
                    elseif floor_calling <= obj.hElevators(i).height    % Branch - Tcover1.1.1.5
                        if direction_calling == "up"    % Branch - Tcover1.1.1.6
                            elevator_hierarchy(i) = 4;
                        elseif direction_calling == "down"    % Branch - Tcover1.1.1.7
                            elevator_hierarchy(i) = 3;
                        end
                    end
                elseif obj.hElevators(i).moving_direction == -1 || obj.hElevators(i).direction_store == -1    % Branch - Tcover1.1.1.8
                    if floor_calling > obj.hElevators(i).height    % Branch - Tcover1.1.1.9
                        if direction_calling == "up"    % Branch - Tcover1.1.1.10
                            elevator_hierarchy(i) = 3;
                        elseif direction_calling == "down"    % Branch - Tcover1.1.1.11
                            elevator_hierarchy(i) = 4;
                        end
                    elseif floor_calling <= obj.hElevators(i).height    % Branch - Tcover1.1.1.12
                        if direction_calling == "up"    % Branch - Tcover1.1.1.13
                            elevator_hierarchy(i) = 2;
                        elseif direction_calling == "down"    % Branch - Tcover1.1.1.14
                            elevator_hierarchy(i) = 1;
                        end
                    end
                % If still, hierarchy=0
                end
                % Special case: emergency or maintain or over_weight
                if obj.hElevators(i).emergency==1 || obj.hElevators(i).maintain==1 || obj.hElevators(i).over_weight==1
                    elevator_hierarchy(i) = 5;
                end
            end
            % Special case: go to basement
            if floor_calling == 1 && direction_calling == "down"    % Branch - Tcover1.1.1.13
                elevator_hierarchy(2) = -1;
            end
            % Special case: basement call
            if floor_calling == 0    % Branch - Tcover1.1.1.14
                elevator_hierarchy(2) = -1;
            end
            
        end
        
        function scheduler(obj, msg_button)
        % Elevator dispatching
            direction_calling = msg_button(1);
            floor_calling = str2double(msg_button(2));
            
            % Build hierarchy
            elevator_hierarchy = obj.buildHierarchy(floor_calling, direction_calling);
            
            % Compare hierarchy
            if elevator_hierarchy(1) < elevator_hierarchy(2)    % Branch - Tcover1.1.2.1
                obj.hElevators(1).addSchedule(floor_calling, direction_calling)
            elseif elevator_hierarchy(1) > elevator_hierarchy(2)    % Branch - Tcover1.1.2.2
                obj.hElevators(2).addSchedule(floor_calling, direction_calling)
            else    % Branch - Tcover1.1.2.3
                dist1 = abs(obj.hElevators(1).height-floor_calling);
                dist2 = abs(obj.hElevators(2).height-floor_calling);
                if dist1 <= dist2    % Branch - Tcover1.1.2.4
                    obj.hElevators(1).addSchedule(floor_calling, direction_calling)
                else    % Branch - Tcover1.1.2.5
                    obj.hElevators(2).addSchedule(floor_calling, direction_calling)
                end
            end
        
        end
        
        function updateState(obj,~,~)
            obj.hElevators(1).updateState;
            obj.hElevators(2).updateState;
            obj.hActivityMonitor.updateState;
            for i = 1:4
                obj.hFloorUI(i).updateState;
            end
        end
    end
    
end