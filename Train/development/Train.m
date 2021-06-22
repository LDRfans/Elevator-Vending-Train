classdef Train < handle
    %    Train class
    %    The train, including global id, train type,train name and
    %    operating parameters
    
    properties
        %%%%  Train Specific  %%%%
        globalID    %  global id
        name    %  train name
        accumulatedDelay    %  accumulated delay till now, unit:s
        speed=0    %  current speed
        acceleration=0    % current acceleration
        location=0    %  location
        distBase=1    %  distance unit 't'
        
        stations = ["S1", "S2", "S3", "S4", "S5", "Termi"];    %  list of stations
        destinations    %  list of destinations
        currStation    %  current or previous station
        nextStation    %  next station in the railway
        nextDest    %  next destination
        targetLocation    %  target location
        
        state    %  0: stopped, 1: accelerating, 2: decelerating, 3: cruising speed, 4: maximum speed
        isStopping    %    1: the train is decelerating to stop
        isAdjusting  %    1: the train is adjusting to cover the gap
        isStarting  %    1: the train is about to start
        
        toMaximum    %    1: is required to accelerate to maximum speed
        gap    %    the distance between the real deceleraing location and the plan decelerating location
        distFromZeroToCru  %    the distance in accelerating from 0 to cruising speed
        distFromCruToZero  %    the distance in decelerating from cruising speed to 0
        distFromCruToMax  %    the distance in accelerating from cruising speed to maximum speed
        distFromMaxToCru  %    the distance in decelerating from maximum speed to cruising speed
        railIndex    %    the index of current rail
        freezeRail    %    1: freeze the rail switching
        panel    %  the display panel of each train
        %%%  schedule, unit: s %%%
        %  original input schedule
        inputSchedule
        %  plan schedule
        planSchedule
        %  real schedule
        realSchedule
        updateScheduleFlag    %  update real schedule
        %%%  schedule, unit:s  %%%
        %%%%  Train Specific  %%%%
        
        %%%%  Type Specific  %%%%
        type    % train type, G/D/K
        cruSpeed    %  cruising speed, unit: t/s
        maxSpeed    %  max speed, unit: t/s
        maxAcceToCru    %  max acceleration(0 -> cruising speed), unit: t/s^2
        maxAcceToMax    %  max acceleration(cruising speed -> max speed), unit: t/s^2
        maxDeceToZero    %  max deceleration(cruising speed -> 0), unit: t/s^2
        maxDeceToCru    %  max deceleration(max speed -> cruising speed), unit: t/s^2
        maxDelay    % max delay, unit: s
        %%%%  Type Specific  %%%%
        
        %%%%  Environment  %%%%
        environment
        %%%%  Environment  %%%%
        
        %%%%  Controller  %%%%
        controller
        %%%%  Controller  %%%%
    end
    
    methods
        function obj = Train(globalID, name, startLeaveTime, S1ArrivalTime, S1LeaveTime, ...
                             S2ArrivalTime, S2LeaveTime, S3ArrivalTime, S3LeaveTime, ...
                             S4ArrivalTime, S4LeaveTime, S5ArrivalTime, S5LeaveTime, ...
                             termiArrivalTime, distBase, environment, controller)
            %    Train constructor
            
            %  Set Train Specfic Properties
            obj.globalID = globalID;
            obj.name = name;
            obj.accumulatedDelay = 0;
            obj.distBase = distBase;
            obj.state = 0;
            obj.isStopping = 0;
            obj.isAdjusting = 0;
            obj.isStarting = 0;
            obj.toMaximum = 0;
            obj.gap = 0;
            obj.railIndex = 0;
            obj.freezeRail = 0;
            obj.environment = environment;
            obj.controller = controller;
                    
            %  Set Schedule Properties
            obj.inputSchedule = Schedule(startLeaveTime, S1ArrivalTime, S1LeaveTime, ...
                             S2ArrivalTime, S2LeaveTime, S3ArrivalTime, S3LeaveTime, ...
                             S4ArrivalTime, S4LeaveTime, S5ArrivalTime, S5LeaveTime, ...
                             termiArrivalTime);        
            obj.planSchedule = Schedule(startLeaveTime, S1ArrivalTime, S1LeaveTime, ...
                             S2ArrivalTime, S2LeaveTime, S3ArrivalTime, S3LeaveTime, ...
                             S4ArrivalTime, S4LeaveTime, S5ArrivalTime, S5LeaveTime, ...
                             termiArrivalTime);
            obj.realSchedule = Schedule(-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
            obj.updateScheduleFlag = 0;
            
            %  Set the destinations
            obj.destinations = ["Termi"];
            if obj.inputSchedule.S5ArrivalTime ~= -1
                obj.destinations = ["S5", obj.destinations];
            end
            if obj.inputSchedule.S4ArrivalTime ~= -1
                obj.destinations = ["S4", obj.destinations];
            end
            if obj.inputSchedule.S3ArrivalTime ~= -1
                obj.destinations = ["S3", obj.destinations];
            end
            if obj.inputSchedule.S2ArrivalTime ~= -1
                obj.destinations = ["S2", obj.destinations];
            end
            if obj.inputSchedule.S1ArrivalTime ~= -1
                obj.destinations = ["S1", obj.destinations];
            end
            
            %  Set Type Specfic Properties
            switch obj.name(1)
                case 'G'
                    obj.type = 'G';
                    obj.cruSpeed = 300 * obj.distBase;
                    obj.maxSpeed = 350 * obj.distBase;
                    obj.maxAcceToCru = 60 * obj.distBase;
                    obj.maxAcceToMax = 25 * obj.distBase;
                    obj.maxDeceToZero = -100 * obj.distBase;
                    obj.maxDeceToCru = -25 * obj.distBase;
                    obj.maxDelay = 10;
                case 'D'
                    obj.type = 'D';
                    obj.cruSpeed = 200 * obj.distBase;
                    obj.maxSpeed = 250 * obj.distBase;
                    obj.maxAcceToCru = 50 * obj.distBase;
                    obj.maxAcceToMax = 25 * obj.distBase;
                    obj.maxDeceToZero = -100 * obj.distBase;
                    obj.maxDeceToCru = -25 * obj.distBase;
                    obj.maxDelay = 15;
                case 'K'
                    obj.type = 'K';
                    obj.cruSpeed = 100 * obj.distBase;
                    obj.maxSpeed = 120 * obj.distBase;
                    obj.maxAcceToCru = 20 * obj.distBase;
                    obj.maxAcceToMax = 10 * obj.distBase;
                    obj.maxDeceToZero = -50 * obj.distBase;
                    obj.maxDeceToCru = -20 * obj.distBase;
                    obj.maxDelay = 30;
                otherwise
                    fprintf("Train Type Error");
            end
            
            obj.distFromZeroToCru = obj.cruSpeed / 2 * (obj.cruSpeed / obj.maxAcceToCru);
            obj.distFromCruToZero = obj.cruSpeed / 2 * (obj.cruSpeed / -obj.maxDeceToZero);
            obj.distFromMaxToCru = (obj.maxSpeed + obj.cruSpeed) / 2 * (obj.maxSpeed - obj.cruSpeed) / -obj.maxDeceToCru;
            obj.distFromCruToMax = (obj.maxSpeed + obj.cruSpeed) / 2 * (obj.maxSpeed - obj.cruSpeed) / obj.maxAcceToMax;
            
            obj.currStation = "Start";
            obj.nextStation = obj.stations(1);
            obj.stations(1) = [];
            obj.nextDest = obj.destinations(1);
            obj.destinations(1) = [];
            obj.targetLocation = obj.environment.getStationPosition(obj.nextDest);
            
            obj.panel = TrainPanel;
            obj.panel.TrainControlPanel.Title = ['Train', ' ', num2str(obj.globalID)];
            obj.panel.train = obj;
            obj.panel.TrainIDEditField.Value = obj.name;
            obj.panel.CruisingSpeedEditField.Value = num2str(obj.cruSpeed);
            obj.panel.MaximumSpeedEditField.Value = num2str(obj.maxSpeed);
            obj.panel.NextStationEditField.Value = obj.nextDest;
            obj.panel.CurrentStateEditField.Value = 'stopped';
            obj.panel.SpeedGauge.Limits(2) = obj.maxSpeed;
            obj.panel.LocationEditField.Value = '0';
            obj.panel.CurrentSpeedEditField.Value = '0';
            obj.panel.AccelerationEditField.Value = '0';
        end
        
        function isFinished = updateState(obj, time, period)    %  main logic
            if time > 120
                obj.name = obj.name;
            end
            %    Return directly if the train is at terminal station
            isFinished = 0;
            if obj.nextDest == "Finished"
                isFinished = 1;
                return
            end
            %    Update the state of the train
            switch obj.state
                case 0    %  stopped
                    if (obj.name(1) == 'K' || obj.name(1) == 'D') && obj.currStation == "S3" && obj.Gbehind() == 1
                        return
                    end
                    planLeaveTime = eval(['obj.', 'planSchedule.', char(obj.currStation), 'LeaveTime']);    %  plan leave time in schedule
                    
                    if abs(time - planLeaveTime) <= 1e-6 || time > planLeaveTime    %  time >= planLeavetime
                        if obj.isStarting == 0    %  not in starting state  
                            obj.isStarting = obj.tryToStart(time);
                        end
                        
                        %    Start with starting flag if 
                        %        1. at start station
                        %        2. don't need to switch rail
                        %        3. switching over
                        if (obj.currStation == "Start" && obj.isStarting == 1)
                            obj.start(time);    %  1
                        elseif obj.currStation ~= "Start"
                            index = obj.railIndex;    %  current rail index
                            station = obj.controller.findStation(obj.currStation);    %  current station
                            if obj.isStarting == 1 && station.mainOutRailIndex == index && station.outSwitchLock == 1
                                obj.start(time);    %  2, 3
                            end
                        end
                        
                    else    %  time < planLeaveTime
                        if obj.isStarting == 0    %  not in starting state
                            if planLeaveTime - time < 1 || abs(planLeaveTime - time - 1) <= 1e-6    %  planLeaveTime - 1 <= time < planLeaveTime
                                if obj.currStation ~= "Start"    %  not at start station
                                    %    Don't start if any train passing
                                    avoid = obj.needAvoiding();
                                    if avoid ~= 1
                                        index = obj.railIndex;
                                        station = obj.controller.findStation(obj.currStation);
                                        if station.mainOutRailIndex ~= index     %  need to switch rail
                                            in = 0;
                                            obj.isStarting = obj.controller.switchRail(station, index, in);
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                case 1    %  accelerating
                    constant = 0;
                    obj.moveForward(constant, period);
                    %  stop accelerating if reaching cruising speed
                    if obj.speed == obj.cruSpeed
                        if obj.toMaximum == 1    %  if required to accelerate to maximum speed
                            obj.toAcceToMax(obj.maxAcceToMax);
                        else
                            obj.toCruisingSpeed();
                        end
                    end
                    %  stop accelerating if reaching maximum speed
                    if obj.speed == obj.maxSpeed
                        obj.toMaximumSpeed();
                    end
                case 2    %  decelerating
                    %    stop decelerating if the train is adjusting to cover the gap
                    if obj.isAdjusting == 1
                        constant = 1;
                        obj.isAdjusting = 0;
                        obj.moveForward(constant, period);
                    else
                        constant = 0;
                        obj.moveForward(constant, period);
                    end
                    
                    %    switch and freeze the rail in advance if the train is stopping
                    if obj.isStopping == 1 && obj.nextDest ~= "Termi"
                        if obj.timeToStop(obj.speed) <= 2 && obj.freezeRail == 0
                            station = obj.controller.findStation(obj.nextDest);
                            in = 1;
                            targetRail = obj.controller.findFreeRail(station);
                            obj.freezeRail = obj.controller.freezeRail(station, targetRail, in, obj.timeToStop(obj.speed));
                        end
                    end
                    
                    %  stop decelerating if reaching 0 speed
                    if obj.speed == 0
                        obj.toStopped();
                        if obj.location == obj.targetLocation    %  if arrive at the target location
                            obj.arrive(time);
                        else 
                            obj.controller.raiseError("Error! The train doesn't stop at the station!");
                        end
                    elseif obj.speed * period == obj.gap    %  if adjustment is needed at next period
                        obj.gap = 0;
                        obj.isAdjusting = 1;
                    end
                    %  change deceleration if reaching crusing speed
                    if obj.speed == obj.cruSpeed
                        obj.toDeceToZero();
                    end
                case 3    %  cruising speed
                    constant = 1;
                    obj.moveForward(constant, period);
                case 4    %  maximum speed
                    constant = 1;
                    obj.moveForward(constant, period);
            end
            
            %    Freeze the rail if the train will pass an unstopped station
            if obj.nextStation ~= obj.nextDest && obj.nextDest ~= "Finished" && obj.isStopping == 0 && obj.freezeRail == 0
                distance = obj.environment.getStationPosition(obj.nextStation) - obj.location;
                timeToPass = distance / obj.speed;
                station = obj.controller.findStation(obj.nextStation);
                if timeToPass <= 2
                    if station.inSwitchLock == 1 && station.outSwitchLock == 1
                        freezeInRail = obj.controller.freezeRail(station, 0, 1, timeToPass);
                        if obj.name(1) ~= 'G'
                            freezeOutRail = obj.controller.freezeRail(station, 0, 0, timeToPass * 2);
                        else
                            freezeOutRail = obj.controller.freezeRail(station, 0, 0, timeToPass);
                        end
                        obj.freezeRail = freezeInRail & freezeOutRail;
                    end
                end
                if abs(distance) <= 1000
                    station.passingTrain = string(obj.name);
                end
            end
            %    Update the next station parameter if passed an unstopped station
            if obj.location > obj.environment.getStationPosition(obj.nextStation) + 1000
                station = obj.controller.findStation(obj.nextStation);
                obj.freezeRail = 0;
                if station.passingTrain == string(obj.name)
                    station.passingTrain = "None";
                end
                obj.nextStation = obj.stations(1);
                obj.stations(1) = [];
            end
            %    Check if need to decelerate to stop
            residue = obj.targetLocation - obj.location;
            if residue == obj.distToStop(obj.speed) && obj.state ~= 0 || obj.location + obj.speed * period > obj.targetLocation - obj.distToStop(obj.speed)
                obj.gap = residue - obj.distToStop(obj.speed);
                obj.isStopping = 1;
                if obj.speed > obj.cruSpeed
                    obj.toDeceToCru();
                else
                    obj.toDeceToZero();
                end
            elseif residue < obj.distToStop(obj.speed)
                obj.controller.raiseError("Too fast! The train cannot stop at next station!");
            end
            obj.panel.updateState;
        end
        
        function toStarting = tryToStart(obj, startTime)
            toStarting = 0;
            %    the adjacent leave time in one station cannot be within 5s
            if obj.currStation == "Start" && obj.controller.lastLeaveTime{1} ~= -5 && startTime - obj.controller.lastLeaveTime{1} < 5 && abs(startTime - obj.controller.lastLeaveTime{1} - 5) > 1e-6
                return
            elseif obj.currStation == "S1" && obj.controller.lastLeaveTime{2} ~= -5 && startTime - obj.controller.lastLeaveTime{2} < 5 && abs(startTime - obj.controller.lastLeaveTime{2} - 5) > 1e-6
                return
            elseif obj.currStation == "S2" && obj.controller.lastLeaveTime{3} ~= -5 && startTime - obj.controller.lastLeaveTime{3} < 5 && abs(startTime - obj.controller.lastLeaveTime{3} - 5) > 1e-6
                return
            elseif obj.currStation == "S3" && obj.controller.lastLeaveTime{4} ~= -5 && startTime - obj.controller.lastLeaveTime{4} < 5 && abs(startTime - obj.controller.lastLeaveTime{4} - 5) > 1e-6
                return
            elseif obj.currStation == "S4" && obj.controller.lastLeaveTime{5} ~= -5 && startTime - obj.controller.lastLeaveTime{5} < 5 && abs(startTime - obj.controller.lastLeaveTime{5} - 5) > 1e-6
                return
            elseif obj.currStation == "S5" && obj.controller.lastLeaveTime{6} ~= -5 && startTime - obj.controller.lastLeaveTime{6} < 5 && abs(startTime - obj.controller.lastLeaveTime{6} - 5) > 1e-6
                return
            end
            
            %    Don't start if any train passing
            if obj.currStation ~= "Start"
                avoid = obj.needAvoiding();
                if avoid == 1
                    return
                end
            end
            
            %    Deal with rails
            if obj.currStation == "Start"    %  can be starting directly
                toStarting = 1;
                return
            else
                index = obj.railIndex;
                station = obj.controller.findStation(obj.currStation);
                if station.mainOutRailIndex ~= index     %  need to switch rail
                    in = 0;
                    toStarting = obj.controller.switchRail(station, index, in);
                else    %  don't need to switch rail
                    if station.outSwitchLock == 1    %  ensure that the rail is not switched by other trains
                        toStarting = 1;
                    end
                end
            end
        end
        
        function start(obj, startTime)
            obj.isStarting = 0;    %  recover
            obj.railIndex = 0;    %  recover
            inputLeaveTime = eval(['obj.', 'inputSchedule.', char(obj.currStation), 'LeaveTime', ';']);
            if startTime > inputLeaveTime && abs(startTime - inputLeaveTime) > 1e-6 && obj.distFromZeroToCru + obj.distFromCruToMax + obj.distFromMaxToCru + obj.distFromCruToZero <= obj.targetLocation - obj.location
                obj.toMaximum = 1;
            end
            obj.toAcceToCru(obj.maxAcceToCru);
            obj.updateScheduleFlag = 1;    %  update real schedule
            eval(['obj.', 'realSchedule.', char(obj.currStation), 'LeaveTime', '=', num2str(startTime), ';']);    %  record the real leave time
            
            if obj.currStation ~= "Start"
                obj.controller.trainLeave(obj.controller.findStation(obj.currStation));
            else
                obj.controller.lastLeaveTime{1} = startTime;
            end
        end
        
        function moveForward(obj, constant, period)
            if constant == 0
                prevSpeed = obj.speed;
                obj.speed = obj.speed + obj.acceleration * period;
%                 %    Set to cruising speed if speed overflow
%                 if obj.acceleration == obj.maxAcceToCru && obj.speed > obj.cruSpeed
%                     obj.speed = obj.cruSpeed;
%                 end
                currSpeed = obj.speed;
                obj.location = obj.location + (currSpeed+prevSpeed)/2 * period;
            else
                obj.location = obj.location + obj.speed * period;
            end
        end
        
        function arrive(obj, arriveTime)
            obj.isStopping = 0;    %  recover
            obj.freezeRail = 0;    %  recover
            obj.currStation = obj.nextDest;    %  update current station
            obj.updateScheduleFlag = 1;    %  update real schedule
            eval(['obj.', 'realSchedule.', char(obj.currStation), 'ArrivalTime', '=', num2str(arriveTime), ';']);    %  Record the real arrival time
            %    Update the parameters if it isn't terminal station
            if obj.currStation ~= "Termi"
                %    Set into the rail
                station = obj.controller.findStation(obj.currStation);
                obj.controller.trainArrive(obj, station);
                %    Set the default leave time of current station if it isn't a destination in plan or it has been late
                planArrivalTime = eval(['obj.', 'planSchedule.', char(obj.currStation), 'ArrivalTime']);
                planLeaveTime = eval(['obj.', 'planSchedule.', char(obj.currStation), 'LeaveTime']);
                if planLeaveTime == -1
                    %    The default leave time is 5s after the arrival
                    eval(['obj.', 'planSchedule.', char(obj.currStation), 'LeaveTime', '=', num2str(arriveTime+5), ';']);
                elseif planArrivalTime < arriveTime && abs(planArrivalTime - arriveTime) > 1e-6
                    interval = planLeaveTime - planArrivalTime;
                    eval(['obj.', 'planSchedule.', char(obj.currStation), 'LeaveTime', '=', num2str(arriveTime+interval), ';']);
                end
                obj.nextStation = obj.stations(1);    %  set the next station(maybe not the destination)
                obj.nextDest = obj.destinations(1);    %  set the next destination
                obj.targetLocation = obj.environment.getStationPosition(obj.nextDest);    %  set the position of next destination
                obj.stations(1) = [];    %  pop the next station
                obj.destinations(1) = [];    %  pop the next destination
            else
                obj.nextDest = "Finished";
            end
        end
        
        function toStopped(obj)    %  state = 0
            obj.state = 0;    %  set to stopped
            obj.acceleration = 0;    %  set the acceleration
        end
        
        function toAcceToCru(obj, acceleration)    %  state = 1
            obj.state = 1;    %  set to accelerating
            obj.acceleration = acceleration;    %  set the acceleration
        end
        
        function toAcceToMax(obj, acceleration)    %  state = 1
            obj.state = 1;
            obj.acceleration = acceleration;    %  set the acceleration to maximum speed
            obj.toMaximum = 0;
        end
        
        function toDeceToCru(obj)    %  state = 2
            obj.state = 2;
            obj.acceleration = obj.maxDeceToCru;
        end
        
        function toDeceToZero(obj)    %  state = 2
            obj.state = 2;
            obj.acceleration = obj.maxDeceToZero;
        end
        
        function toCruisingSpeed(obj)    %  state = 3
            obj.state = 3;    %  set to crusing speed
            obj.acceleration = 0;    %  set the acceleration
        end
        
        function toMaximumSpeed(obj)    %  state = 4
            obj.state = 4;    %  set to maximum speed
            obj.acceleration = 0;    %  set the acceleration
        end
        
        function stopAtNext(obj)    %  UI
            %    Return directly if the train will stop at the next station
            if obj.nextDest == obj.nextStation
                return
            end
            newTarget = obj.environment.getStationPosition(obj.nextStation);
            if newTarget - obj.location < obj.distToStop(obj.speed)
                obj.controller.raiseError("Too late! The train cannot stop at next station!");
                return
            end
            obj.destinations = [obj.nextDest, obj.destinations];    %  Store old destination
            obj.nextDest = obj.nextStation;    %  Update the destination
            obj.targetLocation = obj.environment.getStationPosition(char(obj.nextDest));    %  Update the target locations
        end
        
        function accelerateToCruisingSpeed(obj)    %  UI
            switch obj.state
                case 0    %    Start if it is stopped
                    eval(['obj.', 'planSchedule.', char(obj.currStation), 'LeaveTime', '=', num2str(obj.controller.hSystem.time), ';']); 
                case 1    %    Invalid if it is accelerating
                    if obj.acceleration == obj.maxAcceToCru
                        obj.controller.raiseError("Already accelerating to cruising speed!");
                    else
                        obj.controller.raiseError("Already accelerating to maximum speed!");
                    end
                case 2    %    Two circumstances when it is decelerating
                    if obj.isStopping == 1    %    The train is decelerating to stop, cannot accelerate!
                        obj.controller.raiseError("Cannot accelerate! The train is decelerating to stop!");                        
                    else    %    The train is decelerating to avoid collison, cannot accelerate, raise error!
                        obj.controller.raiseError("Cannot accelerate! The train is decelerating to avoid collision!"); 
                    end
                case 3    %    Invalid if it is running with cruising speed
                    obj.controller.raiseError("Already running with cruising speed!");
                case 4    %    Invalid if it is running with maximum speed
                    obj.controller.raiseError("Already running with maximum speed!");                 
            end
            
        end
        
        function accelerateToMaximumSpeed(obj)    %  UI    case 3 to be modified!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            switch obj.state
                case 0    %    Start if it is stopped
                    obj.toMaximum = 1;
                    eval(['obj.', 'planSchedule.', char(obj.currStation), 'LeaveTime', '=', num2str(obj.controller.hSystem.time), ';']); 
                case 1    %    set the flag if it is accelerating to cruising speed, raise a warning otherwise
                    if obj.acceleration == obj.maxAcceToCru
                        obj.toMaximum = 1;
                    else
                        obj.controller.raiseError("Already accelerating to maximum speed!");
                    end
                case 2    %    Two circumstances when it is decelerating, both invalid
                    if obj.isStopping == 1    %    The train is decelerating to stop, cannot accelerate!
                        obj.controller.raiseError("Cannot accelerate! The train is decelerating to stop!");                        
                    else    %    The train is decelerating to avoid collison, cannot accelerate, raise error!
                        obj.controller.raiseError("Cannot accelerate! The train is decelerating to avoid collision!"); 
                    end
                case 3    %    begin accelerating if it is running with cruising speed and the distance is enough
                    if obj.distFromCruToMax <= obj.targetLocation - obj.location - obj.distToStop(obj.maxSpeed)
                        obj.toAcceToMax(obj.maxAcceToMax);
                    else
                        obj.controller.raiseError("Cannot accelerate! The train will decelerate to stop soon!");
                    end
                case 4    %    Invalid if it is running with maximum speed
                    obj.controller.raiseError("Already running with maximum speed!");
            end
        end
        
        function distance = distToStop(obj, speed)    %  helper function
            digits(10);
            dist1 = 0;
            currSpeed = speed;
            if currSpeed > obj.cruSpeed
                t1 = (obj.cruSpeed - currSpeed)/obj.maxDeceToCru;
                dist1 = (obj.cruSpeed + currSpeed)/2 * t1;
                dist1 = vpa(dist1);
                currSpeed = obj.cruSpeed;
            end
            t2 = -currSpeed / obj.maxDeceToZero;
            dist2 = currSpeed / 2 * t2;
            distance = dist1 + dist2;
            distance = vpa(distance);
        end
        
        function time = timeToStop(obj, speed)    %  helper function
            digits(10);
            t1 = 0;
            currSpeed = speed;
            if currSpeed > obj.cruSpeed
                t1 = (obj.cruSpeed - currSpeed)/obj.maxDeceToCru;
                currSpeed = obj.cruSpeed;
            end
            t2 = -currSpeed / obj.maxDeceToZero;
            time = t1 + t2;
            time = vpa(time);
        end
        
        function distance = distToCru(obj, speed, acceleration)    %  helper function
            distance = 0; %#ok<NASGU>
            if speed < obj.cruSpeed
                time = (obj.cruSpeed - speed) / acceleration;
                distance = (obj.cruSpeed + speed) / 2 * time;
            else
                time = (speed - obj.cruSpeed) / acceleration;
                distance = (obj.cruSpeed + speed) / 2 * time;
            end
        end
        
        function avoid = needAvoiding(obj)
            avoid = 0;
            station = obj.controller.findStation(obj.currStation);
            if station.passingTrain{1}(1) == 'G' || (station.passingTrain{1}(1) == 'D' && obj.name(1) == 'K')    %  all wait G passing and K wait D passing
                passingTrain = obj.controller.findTrain(station.passingTrain);
                if passingTrain.location > obj.location && abs(passingTrain.location - obj.location) > 1e-6 && obj.name(1) == station.passingTrain{1}(1)    %  don't need to avoid if passing train is the same type and has passed
                    avoid = 0;
                else
                    avoid = 1;
                end
            end
        end    %  helper function
        
        function wait = Gbehind(obj)
            wait = 0;
            for i=1:obj.environment.trainNum
                train = obj.environment.trains(i);
                if train.name(1) == 'G' && train.location <= obj.environment.getStationPosition('S3') && train.location > obj.environment.getStationPosition('S1')
                    wait = 1;
                    return
                end
            end
        end    %  helper function
    end
end

