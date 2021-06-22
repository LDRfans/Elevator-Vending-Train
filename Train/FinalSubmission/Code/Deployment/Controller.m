classdef Controller < handle
    %    Controller class
    %    The controller of the system, including the environment and some
    %    controlling methods
    
    properties
        hEnvironment
        hSystem
        lastLeaveTime
    end
    
    methods
        function obj = Controller(inputPath)
            %    Controller constructor
            obj.hEnvironment = Environment(inputPath, obj);
            obj.lastLeaveTime = cell(obj.hEnvironment.stationNum + 1, 1);
            for i=1:length(obj.lastLeaveTime)
                obj.lastLeaveTime{i} = -5;
            end
        end
        
        %    T1.1.1
        function allFinish = updateState(obj, time, period)
            %    The main control function of controller, executed for each
            %    time step.
            
            %    Update the state of environment
            allFinish = obj.hEnvironment.updateState(time, period);
            %    Adjust the train state globally
            obj.adjustTrainState(time);
            %    Statement - Tcover 1.1.1.1
        end
        
        %    T1.1.2
        function adjustTrainState(obj, time)
            %    Adjust the trains' running state from global view
            
            %    Construct a list of running trains
            trainList = obj.removeStoppingTrain(obj.hEnvironment.trains);
            trainList = obj.sortByLocation(trainList);
            %    Adjust the train from the first train on the railway
            for i=length(trainList):-1:2
                %    Get the front train
                frontTrain = trainList(i);
                %    If the front train is the first train on the railway
                %    && it is avoiding collision && the residue distance is
                %    enough for its acceleration and deceleration to stop,
                %    recover.
                if (frontTrain.state == 2 && frontTrain.isStopping == 0) || frontTrain.state == 3
                    %    Branch - Tcover 1.1.2.1
                    if i == length(trainList) && frontTrain.targetLocation - frontTrain.location ...
                        > frontTrain.distToStop(frontTrain.cruSpeed) + frontTrain.distToCru(frontTrain.speed,...
                        obj.findMaxFactor(frontTrain.maxAcceToCru, -frontTrain.maxDeceToZero)) && rem(frontTrain.speed, 1) == 0
                        %    Branch - Tcover 1.1.2.1.1
                        obj.recover(frontTrain);
                    end
                end
                %    Get the back train
                backTrain = trainList(i-1);
                %    Compute the difference between two trains
                difference = frontTrain.location - backTrain.location;
                %    Collision detection
                if abs(difference) < 5
                    %    Branch - Tcover 1.1.2.2
                    obj.raiseMessage(string(['Collision between ', backTrain.name, 'and ', frontTrain.name, '!!!']));
                end
                %    If the back train's speed is higher than the front
                %    train's speed && front train is not stopping && the
                %    difference between them is less than 1000:
                if backTrain.speed > frontTrain.speed && frontTrain.isStopping == 0 && difference < 1000
                    %    Branch - Tcover 1.1.2.3
                    %    If the front train is accelerating:
                    if frontTrain.state == 1
                        %    Branch - Tcover 1.1.2.3.1
                        %    If the back train will catch the front train
                        %    before the front train accelerate to the same
                        %    speed, decelerate.
                        if difference + (backTrain.speed^2 - frontTrain.speed^2)/(2*frontTrain.acceleration)...
                                < backTrain.speed * (backTrain.speed - frontTrain.speed) / frontTrain.acceleration
                            %    Branch - Tcover 1.1.2.3.1.1
                            obj.deceToAvoidCollision(backTrain);
                        end
                    else
                        %    Branch - Tcover 1.1.2.3.2
                        %    Decelerate directly otherwise
                        obj.deceToAvoidCollision(backTrain);
                    end
                %    If the back train is decelerating to avoid collision
                elseif backTrain.isStopping == 0 && backTrain.state == 2
                    %    Branch - Tcover 1.1.2.4
                    %    If the front train is running with constant speed
                    %    and the back train's speed is lower than front
                    %    train's speed, stop decelerating.
                    if (frontTrain.state == 3 || frontTrain.state == 4)  && backTrain.speed < frontTrain.speed
                        %    Branch - Tcover 1.1.2.4.1
                        backTrain.toCruisingSpeed();
                    %    If the front train is accelerating with a higher
                    %    speed, recover.
                    elseif frontTrain.state == 1 && backTrain.speed <= frontTrain.cruSpeed
                        %    Branch - Tcover 1.1.2.4.2
                        obj.recover(backTrain);
                    %    If the difference is large enough, recover.
                    elseif difference >= 1500    %  far enough to recover speed
                        %    Branch - Tcover 1.1.2.4.3
                        obj.recover(backTrain);
                    %    If the front train is stopping, recover.
                    elseif frontTrain.isStopping == 1
                        %    Branch - Tcover 1.1.2.4.4
                        obj.recover(backTrain);
                    end
                %    If the back train is running with constant speed to
                %    avoid collision:
                elseif backTrain.state == 3 && backTrain.speed ~= backTrain.cruSpeed
                    %    Branch - Tcover 1.1.2.5
                    %    If the front train is running with lower constant
                    %    speed, recover.
                    if (frontTrain.state == 3 || frontTrain.state == 4)  && backTrain.speed < frontTrain.speed
                        %    Branch - Tcover 1.1.2.5.1
                        obj.recover(backTrain);
                    %    If the front train is accelerating with a higher
                    %    speed, recover.
                    elseif frontTrain.state == 1 && backTrain.speed <= frontTrain.cruSpeed 
                        %    Branch - Tcover 1.1.2.5.2
                        obj.recover(backTrain);
                    %    If the difference is large enough, recover
                    elseif difference >= 1500
                        %    Branch - Tcover 1.1.2.5.3
                        obj.recover(backTrain);
                    %    If the front train passed the back train's
                    %    destination, recover.
                    elseif frontTrain.location > backTrain.targetLocation
                        %    Branch - Tcover 1.1.2.5.4
                        obj.recover(backTrain);
                    %    If a G train is suppressed and is about to be late
                    elseif (backTrain.targetLocation - backTrain.location) / backTrain.speed ...
                            > eval(['backTrain.planSchedule.', char(backTrain.nextDest), 'ArrivalTime', ';']) - time...
                            && backTrain.name(1) == 'G'
                        %    Branch - Tcover 1.1.2.5.5
                        %    Push the front trains before destination
                        for j=i:length(trainList)
                            nextTrain = trainList(j);
                            if nextTrain.location > backTrain.targetLocation || nextTrain.isStopping == 1 || nextTrain.state == 0
                                %    Branch - Tcover 1.1.2.5.5.1
                                break
                            end
                            if nextTrain.speed >= nextTrain.cruSpeed && nextTrain.speed < nextTrain.maxSpeed
                                %    Branch - Tcover 1.1.2.5.5.2
                                nextTrain.toAcceToMax(obj.findMaxFactor(nextTrain.maxAcceToMax, -nextTrain.maxDeceToCru));
                            elseif nextTrain.speed == nextTrain.maxSpeed
                                %    Branch - Tcover 1.1.2.5.5.3
                                nextTrain.toMaximumSpeed();
                            elseif nextTrain.speed < nextTrain.cruSpeed
                                %    Branch - Tcover 1.1.2.5.5.4
                                nextTrain.toAcceToCru(obj.findMaxFactor(nextTrain.maxAcceToCru, -nextTrain.maxDeceToZero));
                            end
                        end
                    end
                end
            end
        end
        
        %    T1.1.3
        function trainLeave(obj, station)
            %    Reset the rail information
            station.rails{station.mainOutRailIndex + 1}.currentTrainName = "None";
            in = 0;
            obj.switchRail(station, 0, in);    %  recover
            %    Record real leave time
            if station.name == "S1"
                %    Branch - Tcover 1.1.3.1
                obj.lastLeaveTime{2} = obj.hSystem.time;
            elseif station.name == "S2"
                %    Branch - Tcover 1.1.3.2
                obj.lastLeaveTime{3} = obj.hSystem.time;
            elseif station.name == "S3"
                %    Branch - Tcover 1.1.3.3
                obj.lastLeaveTime{4} = obj.hSystem.time;
            elseif station.name == "S4"
                %    Branch - Tcover 1.1.3.4
                obj.lastLeaveTime{5} = obj.hSystem.time;
            elseif station.name == "S5"
                %    Branch - Tcover 1.1.3.5
                obj.lastLeaveTime{6} = obj.hSystem.time;
            end
        end
        
        %    T1.1.4
        function trainArrive(obj, train, station)
            %    Set the rail information
            station.rails{station.mainInRailIndex + 1}.currentTrainName = train.name;
            train.railIndex = station.mainInRailIndex;
            in = 1;
            obj.switchRail(station, 0, in);
            %    Statement - Tcover 1.1.4.1
        end
        
        %    T1.1.5
        function index = findFreeRail(obj, station)
            for index=2:station.totalRailNum
                rail = station.rails{index};
                if rail.currentTrainName == "None"
                    %    Branch - Tcover 1.1.5.1
                    index = index - 1; %#ok<FXSET>
                    return
                end
            end
            %    Branch - Tcover 1.1.5.2
            obj.raiseMessage(string(['Rails are full in station ', station.name]));
            index = -1;
        end
        
        %    T1.1.6
        function result = switchRail(~, station, index, in)
            result = 0;
            if in == 1
                %    Branch - Tcover 1.1.6.1
                if station.inSwitchLock == 0
                    %    Branch - Tcover 1.1.6.1.1
                    return
                end
                %    Branch - Tcover 1.1.6.1.2
                station.inSwitchLock = 0;
                station.rails{station.mainInRailIndex + 1}.mainInFlag = 0;
                station.mainInRailIndex = index;
                station.rails{index + 1}.mainInFlag = 1;
                station.inSwitchTime = 1;
                result = 1;
            else
                %    Branch - Tcover 1.1.6.2
                if station.outSwitchLock == 0
                    %    Branch - Tcover 1.1.6.2.1
                    return
                end
                %    Branch - Tcover 1.1.6.2.2
                station.outSwitchLock = 0;
                station.rails{station.mainOutRailIndex + 1}.mainOutFlag = 0;
                station.mainOutRailIndex = index;
                station.rails{index + 1}.mainOutFlag = 1;
                station.outSwitchTime = 1;
                result = 1;
            end
        end
        
        %    T1.1.7
        function result = freezeRail(obj, station, index, in, time)
            result = 0;
            switchResult = obj.switchRail(station, index, in);
            if switchResult == 1
                %    Branch - Tcover 1.1.7.1
                result = 1;
                if time > 1
                    %    Branch - Tcover 1.1.7.1.1
                    if in == 1
                        %    Branch - Tcover 1.1.7.1.1.1
                        station.inSwitchTime = time;
                    else
                        %    Branch - Tcover 1.1.7.1.1.2
                        station.outSwitchTime = time;
                    end
                end
            end
        end
        
        %    T1.1.8
        function deceToAvoidCollision(~, train)
            if (train.speed > 200 && rem(train.speed, 10) == 0) || rem(train.speed, 20) == 0
                %    Branch - Tcover 1.1.8.1
                if train.speed > train.cruSpeed
                    %    Branch - Tcover 1.1.8.1.1
                    train.toDeceToCru();
                else
                    %    Branch - Tcover 1.1.8.1.2
                    train.toDeceToZero();
                end
            end
        end
        
        %    T1.1.9
        function recover(obj, train)
            if rem(train.location, 1) ~= 0
                %    Branch - Tcover 1.1.9.1
                return
            end
            %    Branch - Tcover 1.1.9.2
            if train.speed > train.cruSpeed
                %    Branch - Tcover 1.1.9.2.1
                train.toAcceToMax(obj.findMaxFactor(train.maxAcceToMax, -train.maxDeceToCru));
            elseif train.speed == train.cruSpeed
                %    Branch - Tcover 1.1.9.2.2
                train.toCruisingSpeed();
            elseif train.speed == train.maxSpeed
                %    Branch - Tcover 1.1.9.2.3
                train.toMaximumSpeed();
            else
                %    Branch - Tcover 1.1.9.2.4
                train.toAcceToCru(obj.findMaxFactor(train.maxAcceToCru, -train.maxDeceToZero));
            end
        end
        
        %    T1.1.10
        function raiseMessage(obj, str)
            e = Message;
            e.hSystem = obj.hSystem;
            e.Label.Text = str;
            stop(obj.hSystem.t);
            %    Statement - Tcover 1.1.10.1
        end
        
        %    T1.1.11
        function station = findStation(obj, name)    %  helper function
            for i=1:obj.hEnvironment.stationNum
                station = obj.hEnvironment.stations{i};
                if char(station.name) == name
                    %    Branch - Tcover 1.1.11.1
                    return
                end
            end
            %    Branch - Tcover 1.1.11.2
            obj.raiseMessage("Invalid station name!!!");
        end
        
        %    T1.1.12
        function train = findTrain(obj, name)    %  helper function
            for i=1:obj.hEnvironment.trainNum
                train = obj.hEnvironment.trains(i);
                if char(train.name) == name
                    %    Branch - Tcover 1.1.12.1
                    return
                end
            end
            %    Branch - Tcover 1.1.12.2
            obj.raiseMessage("Invalid train name!!!");
        end
        
        %    T1.1.13
        function trainList = removeStoppingTrain(~, trains)    %  helper function
            i = 1;
            trainList = trains;
            while i <= length(trainList)
                if trainList(i).state == 0
                    %    Branch - Tcover 1.1.13.1
                    trainList(i) = [];
                    continue
                end
                %    Branch - Tcover 1.1.13.2
                i = i + 1;
            end
        end
        
        %    T1.1.14
        function sortedTrainList = sortByLocation(~, trainList)    %  helper function
            sortedTrainList = trainList;
            if length(sortedTrainList) == 1
                %    Branch - Tcover 1.1.14.1
                return
            end
            %    Branch - Tcover 1.1.14.2
            for i=2:length(sortedTrainList)
                train = sortedTrainList(i);
                j = i-1;
                while j>0 && train.location < sortedTrainList(j).location
                    sortedTrainList(j+1) = sortedTrainList(j);
                    j = j-1;
                end
                sortedTrainList(j+1) = train;
            end
        end
        
        %    T1.1.15
        function sortedTrainList = sortByType(~, trainList)    %  helper function
            sortedTrainList = trainList;
            if length(sortedTrainList) == 1
                %    Branch - Tcover 1.1.15.1
                return
            end
            %    Branch - Tcover 1.1.15.2
            for i=2:length(sortedTrainList)
                train = sortedTrainList(i);
                j = i-1;
                while j>0 && train.maxSpeed > sortedTrainList(j).maxSpeed
                    sortedTrainList(j+1) = sortedTrainList(j);
                    j = j-1;
                end
                sortedTrainList(j+1) = train;
            end
        end
        
        %    T1.1.16
        function sortedTrainList = sortByLeaveTime(obj, trainList)    %  helper function
            station = obj.findStation(trainList(1).currStation);
            sortedTrainList = trainList;
            if length(sortedTrainList) == 1
                %    Branch - Tcover 1.1.16.1
                return
            end
            %    Branch - Tcover 1.1.16.2
            for i=2:length(sortedTrainList)
                train = sortedTrainList(i);
                j = i-1;
                currLeaveTime = eval(['train.planSchedule.', char(station.name), 'LeaveTime', ';']);
                while j>0 && currLeaveTime < eval(['sortedTrainList(j).planSchedule.', char(station.name), 'LeaveTime', ';'])
                    sortedTrainList(j+1) = sortedTrainList(j);
                    j = j-1;
                end
                sortedTrainList(j+1) = train;
            end
        end
        
        %    T1.1.17
        function sortedTrainList = sortByTypeAndLeaveTime(obj, trainList)    %  helper function
            sortedTrainList = obj.sortByLeaveTime(trainList);
            sortedTrainList = obj.sortByType(sortedTrainList);
            %    Statement - Tcover 1.1.17.1
        end
        
        %    T1.1.18
        function n = findMaxFactor(~, a, b)    %  helper function
            for n=a:-1:1
                if rem(b/n, 1) == 0
                    %    Branch - Tcover 1.1.18.1
                    return
                end
            end
        end
    end
end

