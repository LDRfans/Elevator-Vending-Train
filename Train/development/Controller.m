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
        
        function allFinish = updateState(obj, time, period)
            %    Update the state of environment
            allFinish = obj.hEnvironment.updateState(time, period);
            
            %    Decelerate the back train to avoid collison
            trainList = obj.removeStoppingTrain(obj.hEnvironment.trains);
            trainList = obj.sortByLocation(trainList);
            for i=length(trainList):-1:2
                frontTrain = trainList(i);
                if (frontTrain.state == 2 && frontTrain.isStopping == 0) || frontTrain.state == 3
                    if i == length(trainList) && frontTrain.targetLocation - frontTrain.location ...
                        > frontTrain.distToStop(frontTrain.cruSpeed) + frontTrain.distToCru(frontTrain.speed,...
                        obj.findMaxFactor(frontTrain.maxAcceToCru, -frontTrain.maxDeceToZero)) && rem(frontTrain.speed, 1) == 0
                        obj.recover(frontTrain);
                    end
                end
                backTrain = trainList(i-1);                
                difference = frontTrain.location - backTrain.location;
                %    Collision detection
                if abs(difference) < 5
                    obj.raiseError(string(['Collision between', backTrain.name, frontTrain.name, '!!!']));
                end
                
                if backTrain.speed > frontTrain.speed && frontTrain.isStopping == 0 && difference < 1000
                    if frontTrain.state == 1
                        if difference + (backTrain.speed^2 - frontTrain.speed^2)/(2*frontTrain.acceleration) < backTrain.speed * (backTrain.speed - frontTrain.speed) / frontTrain.acceleration
                            obj.deceToAvoidCollision(backTrain);
                        end
                    else
                        obj.deceToAvoidCollision(backTrain);
                    end
                elseif backTrain.isStopping == 0 && backTrain.state == 2
                    if (frontTrain.state == 3 || frontTrain.state == 4)  && backTrain.speed <= frontTrain.speed    %  constant speed
                        backTrain.toCruisingSpeed();
                    elseif frontTrain.state == 1 && backTrain.speed <= frontTrain.cruSpeed    %  front train accelerating with higher speed
                        obj.recover(backTrain);
                    elseif difference >= 1500    %  far enough to recover speed
                        obj.recover(backTrain);
                    elseif frontTrain.isStopping == 1
                        obj.recover(backTrain);
                    end
                elseif backTrain.state == 3 && backTrain.speed ~= backTrain.cruSpeed
                    if (frontTrain.state == 3 || frontTrain.state == 4)  && backTrain.speed < frontTrain.speed
                        obj.recover(backTrain);
                    elseif frontTrain.state == 1 && backTrain.speed <= frontTrain.cruSpeed 
                        obj.recover(backTrain);
                    elseif difference >= 1500
                        obj.recover(backTrain);
                    elseif frontTrain.location > backTrain.targetLocation
                        obj.recover(backTrain);
                    elseif (backTrain.targetLocation - backTrain.location) / backTrain.speed ...
                            > eval(['backTrain.planSchedule.', char(backTrain.nextDest), 'ArrivalTime', ';']) - time...
                            && backTrain.name(1) == 'G'
                        for j=i:length(trainList)
                            nextTrain = trainList(j);
                            if nextTrain.location > backTrain.targetLocation || nextTrain.isStopping == 1 || nextTrain.state == 0
                                break
                            end
                            if nextTrain.speed >= nextTrain.cruSpeed && nextTrain.speed < nextTrain.maxSpeed
                                nextTrain.toAcceToMax(obj.findMaxFactor(nextTrain.maxAcceToMax, -nextTrain.maxDeceToCru));
                            elseif nextTrain.speed == nextTrain.maxSpeed
                                nextTrain.toMaximumSpeed();
                            elseif nextTrain.speed < nextTrain.cruSpeed
                                nextTrain.toAcceToCru(obj.findMaxFactor(nextTrain.maxAcceToCru, -nextTrain.maxDeceToZero));
                            end
                        end
                    end
                end
            end
        end
        
        function trainLeave(obj, station)
            station.rails{station.mainOutRailIndex + 1}.currentTrainName = "None";    %  recover
            in = 0;
            obj.switchRail(station, 0, in);    %  recover
            %    Record real leave time
            if station.name == "S1"
                obj.lastLeaveTime{2} = obj.hSystem.time;
            elseif station.name == "S2"
                obj.lastLeaveTime{3} = obj.hSystem.time;
            elseif station.name == "S3"
                obj.lastLeaveTime{4} = obj.hSystem.time;
            elseif station.name == "S4"
                obj.lastLeaveTime{5} = obj.hSystem.time;
            elseif station.name == "S5"
                obj.lastLeaveTime{6} = obj.hSystem.time;
            end
        end
        
        function trainArrive(obj, train, station)
%             station.inSwitchLock = 1;
            station.rails{station.mainInRailIndex + 1}.currentTrainName = train.name;
            train.railIndex = station.mainInRailIndex;
            in = 1;
            obj.switchRail(station, 0, in);
        end
        
        function index = findFreeRail(obj, station)
            for index=2:station.totalRailNum
                rail = station.rails{index};
                if rail.currentTrainName == "None"
                    index = index - 1; %#ok<FXSET>
                    return
                end
            end
            obj.raiseError(string(['Rails are full in station ', station.name]));
            index = -1;
        end
        
        function result = switchRail(~, station, index, in)
            result = 0;
            if in == 1
                if station.inSwitchLock == 0
                    %obj.raiseError("Cannot switch the rail now!");
                    return
                end
                station.inSwitchLock = 0;
                station.rails{station.mainInRailIndex + 1}.mainInFlag = 0;
                station.mainInRailIndex = index;
                station.rails{index + 1}.mainInFlag = 1;
                station.inSwitchTime = 1;
                result = 1;
            else
                if station.outSwitchLock == 0
                    %obj.raiseError("Cannot switch the rail now!");
                    return
                end
                station.outSwitchLock = 0;
                station.rails{station.mainOutRailIndex + 1}.mainOutFlag = 0;
                station.mainOutRailIndex = index;
                station.rails{index + 1}.mainOutFlag = 1;
                station.outSwitchTime = 1;
                result = 1;
            end
        end
        
        function result = freezeRail(obj, station, index, in, time)
            result = 0;
            switchResult = obj.switchRail(station, index, in);
            if switchResult == 1
                result = 1;
                if time > 1
                    if in == 1
                        station.inSwitchTime = time;
                    else
                        station.outSwitchTime = time;
                    end
                end
            end
        end
        
        function station = findStation(obj, name)
            for i=1:obj.hEnvironment.stationNum
                station = obj.hEnvironment.stations{i};
                if char(station.name) == name
                    return
                end
            end
            obj.raiseError("Invalid station name!!!");
        end
        
        function train = findTrain(obj, name)
            for i=1:obj.hEnvironment.trainNum
                train = obj.hEnvironment.trains(i);
                if char(train.name) == name
                    return
                end
            end
        end
        
        function trainList = removeStoppingTrain(~, trains)
            i = 1;
            trainList = trains;
            while i <= length(trainList)
                if trainList(i).state == 0
                    trainList(i) = [];
                    continue
                end
                i = i + 1;
            end
        end
        
        function deceToAvoidCollision(~, train)
            if (train.speed > 200 && rem(train.speed, 10) == 0) || rem(train.speed, 20) == 0
                if train.speed > train.cruSpeed
                    train.toDeceToCru();
                else
                    train.toDeceToZero();
                end
            end
        end
        
        function recover(obj, train)
            if rem(train.location, 1) ~= 0
                return
            end
            
            if train.speed > train.cruSpeed
                train.toAcceToMax(obj.findMaxFactor(train.maxAcceToMax, -train.maxDeceToCru));
            elseif train.speed == train.cruSpeed
                train.toCruisingSpeed();
            elseif train.speed == train.maxSpeed
                train.toMaximumSpeed();
            else
                train.toAcceToCru(obj.findMaxFactor(train.maxAcceToCru, -train.maxDeceToZero));
            end
        end
        
        function sortedTrainList = sortByLocation(~, trainList)
            sortedTrainList = trainList;
            if length(sortedTrainList) == 1
                return
            end
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
        
        function sortedTrainList = sortByType(~, trainList)
            sortedTrainList = trainList;
            if length(sortedTrainList) == 1
                return
            end
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
        
        function sortedTrainList = sortByLeaveTime(obj, trainList)
            station = obj.findStation(trainList(1).currStation);
            sortedTrainList = trainList;
            if length(sortedTrainList) == 1
                return
            end
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
        
        function sortedTrainList = sortByTypeAndLeaveTime(obj, trainList)
            sortedTrainList = obj.sortByLeaveTime(trainList);
            sortedTrainList = obj.sortByType(sortedTrainList);
        end
        
        function raiseError(obj, str)
            e = Error;
            e.hSystem = obj.hSystem;
            e.Label.Text = str;
            stop(obj.hSystem.t);
        end
        
        function n = findMaxFactor(~, a, b)
            for n=a:-1:1
                if rem(b/n, 1) == 0
                    return
                end
            end
        end
    end
end

