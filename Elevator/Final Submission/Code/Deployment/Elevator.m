classdef Elevator < handle
    properties
        name
        floor  % int
        height % float
        unit_height = 1
        velocity = 0
        velocity_max = 0.2
        accelerate = 0.1
        height_limit
        weight_limit
        moving_up_queue = []
        moving_down_queue = []
        moving_up_queue_store = []
        moving_down_queue_store = []
        moving_direction = 0
        direction_store = 0
        door_open = 0
        timer_door = 0
        emergency = 0
        over_weight = 0
        maintain = 0
        door_stuck = 0
        error = 0
        
        floor_target = 0
        accelerate_status = 0
        door_status = "close"
        
        hCarUI
        hSystemController
    end
    
    methods
        function obj=Elevator(name, floor, height_limit, weight_limit)
            obj.name = name;
            obj.floor = floor;
            obj.height = floor;
            obj.height_limit = height_limit;
            obj.weight_limit = weight_limit;
            
            % Inside Caller
            obj.hCarUI = CarUI;
            obj.hCarUI.hElevator = obj;
            obj.hCarUI.init;
        end
        
        function updateState(obj)
            
            if (obj.emergency==1 || obj.maintain==1 || obj.over_weight==1) == 0
                obj.updateQueue();

                obj.move();
                obj.movingDirector();   % get direction

                obj.updateFloor();
                obj.updateTargetFloor();
            end

            obj.hCarUI.updateState;

        end


        function movingDirector(obj)
            % If moving up
            flag1 = 0;
            flag2 = 0;
            if obj.moving_direction == 1    % Branch - Tcover1.2.1.1
                if isempty(obj.moving_up_queue) == 0    % Branch - Tcover1.2.1.2
                    if obj.floor < obj.moving_up_queue(end) % Branch - Tcover1.2.1.3
                        flag1 = 1;
                    end
                end
                if isempty(obj.moving_down_queue) == 0  % Branch - Tcover1.2.1.4
                    if obj.floor < obj.moving_down_queue(1) % Branch - Tcover1.2.1.5
                        flag2 = 1;
                    end
                end
            elseif obj.moving_direction == -1   % Branch - Tcover1.2.1.6
                if isempty(obj.moving_up_queue) == 0    % Branch - Tcover1.2.1.7
                    if obj.floor > obj.moving_up_queue(1)   % Branch - Tcover1.2.1.8
                        flag1 = 1;
                    end
                end
                if isempty(obj.moving_down_queue) == 0  % Branch - Tcover1.2.1.9
                    if obj.floor > obj.moving_down_queue(end)   % Branch - Tcover1.2.1.10
                        flag2 = 1;
                    end
                end
            else  % still, Redirecting  % Branch - Tcover1.2.1.11
                if isempty(obj.moving_up_queue) == 0    % Branch - Tcover1.2.1.12
                    if obj.floor > obj.moving_up_queue(1)   % Branch - Tcover1.2.1.13
                        obj.moving_direction = -1;
                        flag1 = 1;
                    elseif obj.floor < obj.moving_up_queue(1)   % Branch - Tcover1.2.1.14
                        obj.moving_direction = 1;
                        flag2 = 1;
                    end
                elseif isempty(obj.moving_down_queue) == 0  % Branch - Tcover1.2.1.15
                    if obj.floor < obj.moving_down_queue(1) % Branch - Tcover1.2.1.16
                        obj.moving_direction = 1;
                        flag1 = 1;
                    elseif obj.floor > obj.moving_down_queue(1) % Branch - Tcover1.2.1.17
                        obj.moving_direction = -1;
                        flag2 = 1;
                    end
                end
            end
            % Stop condition
            if obj.door_open == 1   % Branch - Tcover1.2.1.18
                obj.moving_direction = 0;
            end
            if flag1==0 && flag2==0 % Branch - Tcover1.2.1.19
                obj.moving_direction = 0;
            end
        end
        
        function Accelerate(obj)
            if obj.velocity < obj.velocity_max  % Branch - Tcover1.2.2.1
                obj.accelerate_status = 1;
                obj.velocity = obj.velocity + obj.accelerate;
            elseif obj.velocity > obj.velocity_max  % Branch - Tcover1.2.2.2
                obj.velocity = obj.velocity_max;
            end
            % Update accelerate status
            if obj.velocity >= obj.velocity_max  % Branch - Tcover1.2.2.3
                obj.accelerate_status = 0;
            end
        end
        
        function Decelerate(obj)
            if obj.velocity > 0  % Branch - Tcover1.2.3.1
                obj.accelerate_status = -1;
                obj.velocity = obj.velocity - obj.accelerate;
            elseif obj.velocity < 0  % Branch - Tcover1.2.3.2
                obj.velocity = 0;
            end
            % Update accelerate status
            if obj.velocity <= 0  % Branch - Tcover1.2.3.3
                obj.accelerate_status = 0;
            end
        end
        
        function move(obj)
        % Update height as the elevator moving
        
            % Accelerate
            if obj.accelerate_status ~= -1 && obj.moving_direction ~= 0  % Branch - Tcover1.2.4.1
                obj.Accelerate();
            end
            % Decelerate
            if obj.accelerate_status ~= 1  % Branch - Tcover1.2.4.2
                % moving down
                if obj.moving_direction==-1 && -0.000001 < obj.height-obj.floor_target && obj.height-obj.floor_target <= 0.1+0.000001  % Branch - Tcover1.2.4.3
                    obj.Decelerate();
                end
                % moving up
                if obj.moving_direction==1 && -0.000001 < obj.floor_target-obj.height && obj.floor_target-obj.height <= 0.1+0.000001  % Branch - Tcover1.2.4.4
                    obj.Decelerate();
                end
            end
            % Update height
            switch obj.moving_direction
                case 1  % moving upward
                    if obj.height+obj.velocity <= obj.height_limit(2)  % Branch - Tcover1.2.4.5
                        obj.height = obj.height + obj.velocity;
                    else  % Branch - Tcover1.2.4.6
                        obj.height = obj.height_limit(2);
                    end
                case -1 % moving downward
                    if obj.height-obj.velocity >= obj.height_limit(1)  % Branch - Tcover1.2.4.7
                        obj.height = obj.height - obj.velocity;
                    else  % Branch - Tcover1.2.4.8
                        obj.height = obj.height_limit(1);
                    end
            end

        end
        
        function updateFloor(obj)
            if obj.moving_direction == 1   % is moving up  % Branch - Tcover1.2.5.1
                obj.floor = floor(obj.height+0.000001); %#ok<*CPROP>
            elseif obj.moving_direction == -1  % is moving down  % Branch - Tcover1.2.5.2
                obj.floor = ceil(obj.height-0.000001);
            else  % is still  % Branch - Tcover1.2.5.3
                obj.floor = floor(obj.height+0.000001);
            end
        end
        
        function updateQueue(obj)
            % update moving_up_queue & moving_down_queue
            if obj.moving_direction==1 && isempty(obj.moving_up_queue)==0  % Branch - Tcover1.2.6.1
                if obj.floor == obj.moving_up_queue(1) && obj.height-0.000001 < obj.moving_up_queue(1)  % Branch - Tcover1.2.6.2
                    obj.moving_up_queue(1) = [];
                    % Store direction
                    obj.direction_store = obj.moving_direction;
                    obj.door_open = 1;
                    obj.hSystemController.hFloorUI(obj.floor+1).lightOff(1,obj.floor);
                end
            elseif obj.moving_direction==-1 && isempty(obj.moving_down_queue)==0  % Branch - Tcover1.2.6.3
                if obj.floor == obj.moving_down_queue(1) && obj.height+0.000001 > obj.moving_down_queue(1)  % Branch - Tcover1.2.6.4
                    obj.moving_down_queue(1) = [];
                    % Store direction
                    obj.direction_store = obj.moving_direction;
                    obj.door_open = 1;
                    obj.hSystemController.hFloorUI(obj.floor+1).lightOff(-1,obj.floor);
                end
            elseif obj.moving_direction==0  % Branch - Tcover1.2.6.5
                % Load stored queue
                if isempty(obj.moving_up_queue)
                    obj.moving_up_queue = obj.moving_up_queue_store;
                    obj.moving_up_queue_store = [];
                end
                if isempty(obj.moving_down_queue)
                    obj.moving_down_queue = obj.moving_down_queue_store;
                    obj.moving_down_queue_store = [];
                end
                % At up start place
                if isempty(obj.moving_up_queue)==0  % Branch - Tcover1.2.6.6
                    if obj.floor == obj.moving_up_queue(1)  % Branch - Tcover1.2.6.7
                        obj.moving_up_queue(1) = [];
                        obj.door_open = 1;
                        obj.hSystemController.hFloorUI(obj.floor+1).lightOff(1,obj.floor);
                        return
                    end
                end
                % At down start place
                if isempty(obj.moving_down_queue)==0  % Branch - Tcover1.2.6.8
                    if obj.floor == obj.moving_down_queue(1)  % Branch - Tcover1.2.6.9
                        obj.moving_down_queue(1) = [];
                        obj.door_open = 1;
                        obj.hSystemController.hFloorUI(obj.floor+1).lightOff(-1,obj.floor);
                        return
                    end
                end
            end
        end
                
        function updateTargetFloor(obj)
            % Moving up
            if obj.moving_direction == 1  % Branch - Tcover1.2.7.1
                if isempty(obj.moving_up_queue)==0  % Branch - Tcover1.2.7.2
                    obj.floor_target = obj.moving_up_queue(1);
                elseif isempty(obj.moving_down_queue)==0  % Branch - Tcover1.2.7.3
                    obj.floor_target = obj.moving_down_queue(1);
                end
            elseif obj.moving_direction == -1  % Branch - Tcover1.2.7.4
                if isempty(obj.moving_down_queue)==0  % Branch - Tcover1.2.7.5
                    obj.floor_target = obj.moving_down_queue(1);
                elseif isempty(obj.moving_up_queue)==0  % Branch - Tcover1.2.7.6
                    obj.floor_target = obj.moving_up_queue(1);
                end
            end
        end
        
        
        function addSchedule(obj, target_floor, direction_call)
        % Add target floor to the queue
            if direction_call == "up"  % Branch - Tcover1.2.8.1
                if obj.height > target_floor
                    obj.moving_up_queue_store = [obj.moving_up_queue_store target_floor];
                    obj.moving_up_queue_store = sort(obj.moving_up_queue_store, 'ascend');
                else
                    obj.moving_up_queue = [obj.moving_up_queue target_floor];
                    obj.moving_up_queue = sort(obj.moving_up_queue, 'ascend');
                end
                
            elseif direction_call == "down"  % Branch - Tcover1.2.8.2
                if obj.height < target_floor
                    obj.moving_down_queue_store = [obj.moving_down_queue_store target_floor];
                    obj.moving_down_queue_store = sort(obj.moving_down_queue_store, 'descend');
                else
                    obj.moving_down_queue = [obj.moving_down_queue target_floor];
                    obj.moving_down_queue = sort(obj.moving_down_queue, 'descend');
                end
            end
        end
        
    end

end