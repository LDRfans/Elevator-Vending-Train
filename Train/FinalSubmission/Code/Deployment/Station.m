classdef Station < handle
    %    Station class
    %    The station, including the name, main railway index and total
    %    number of railway
    
    properties
        name
        prevStation
        nextStation
        totalRailNum
        rails
        mainInRailIndex
        mainOutRailIndex
        inSwitchLock
        outSwitchLock
        inSwitchTime
        outSwitchTime
        passingTrain
        hController
    end
    
    methods
        function obj = Station(name, prevStation, nextStation, totalRailNum, mainInRailIndex, mainOutRailIndex, controller)
            %    Station constructor
            obj.name = name;
            obj.prevStation = prevStation;
            obj.nextStation = nextStation;
            obj.totalRailNum = totalRailNum;
            obj.mainInRailIndex = mainInRailIndex;
            obj.mainOutRailIndex = mainOutRailIndex;
            obj.rails = cell(obj.totalRailNum, 1);
            for i = 1:obj.totalRailNum
                if i == obj.mainInRailIndex + 1
                    mainInFlag = 1;
                else
                    mainInFlag = 0;
                end
                
                if i == obj.mainOutRailIndex + 1
                    mainOutFlag = 1;
                else
                    mainOutFlag = 0;
                end
                obj.rails{i} = Rail(mainInFlag, mainOutFlag);
            end
            obj.inSwitchLock = 1;
            obj.outSwitchLock = 1;
            obj.inSwitchTime = 0;
            obj.outSwitchTime = 0;
            obj.passingTrain = "None";
            obj.hController = controller;
        end
        
        %    T1.3.1
        function updateState(obj, period)
            if obj.inSwitchTime ~= 0
                %    Branch - Tcover 1.3.1.1
                obj.inSwitchTime = obj.inSwitchTime - period;
            end
            
            if obj.outSwitchTime ~= 0
                %    Branch - Tcover 1.3.1.2
                obj.outSwitchTime = obj.outSwitchTime - period;
            end
            
            if obj.inSwitchTime < 0.001
                %    Branch - Tcover 1.3.1.3
                obj.inSwitchTime = 0;
            end
            
            if obj.outSwitchTime < 0.001
                %    Branch - Tcover 1.3.1.4
                obj.outSwitchTime = 0;
            end
            
            if obj.inSwitchTime == 0
                %    Branch - Tcover 1.3.1.5
                obj.inSwitchLock = 1;
            end
            
            if obj.outSwitchTime == 0
                %    Branch - Tcover 1.3.1.6
                obj.outSwitchLock = 1;
            end
            
            %    Rearrange the leave time of trains
            obj.rearrangeTrainLeaveTime();
        end
        
        %    T1.3.2
        function rearrangeTrainLeaveTime(obj)
            trainList = [];
            for i=1:obj.totalRailNum - 1
                if obj.rails{i+1}.currentTrainName ~= "None"
                    %    Branch - Tcover 1.3.2.1
                    trainList = [obj.hController.findTrain(obj.rails{i+1}.currentTrainName), trainList]; %#ok<AGROW>
                end
            end
            if length(trainList) >= 2
                %    Branch - Tcover 1.3.2.2
                sortedTrainList = obj.hController.sortByTypeAndLeaveTime(trainList);
                firstTrain = sortedTrainList(1);
                leaveTime = eval(['firstTrain.planSchedule.', char(firstTrain.currStation), 'LeaveTime']);
                for i=2:length(sortedTrainList)
                    train = sortedTrainList(i);
                    prevLeaveTime = eval(['train.planSchedule.', char(train.currStation), 'LeaveTime']);
                    newLeaveTime = max(prevLeaveTime, leaveTime+5);
                    eval(['train.planSchedule.', char(train.currStation), 'LeaveTime=newLeaveTime', ';']);
                    leaveTime = newLeaveTime;
                end
            end
        end
    end
end

