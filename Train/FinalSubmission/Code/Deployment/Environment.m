classdef Environment < handle
    %    Environment class
    %    The whole environment information, including trains, stations,
    %    railways.
    
    properties
        %%%%  Environment Parameters  %%%%
        stationNum = 5     %  the number of stations
        stationNames = {'S1', 'S2', 'S3', 'S4', 'S5'}    %  the name of the stations
        railwayNum = 6     %  the number of railways(the road between two stations)
        railNums = [3, 2, 4, 2, 4]    %  the number of rails for each station
        railwayLengths = [4800, 2400, 3000, 1800, 7200, 2400]    %  the lengths between stations
        layout = [4800, 7200, 10200, 12000, 19200, 21600]    %  the layout of the stations
        railwayLength = 21600    %  the total length of railway
        switchCost = 1    %  the cost of switching from secondary rail to main rail
        distBase = 1    %  the unit 't'
        %%%%  Environment Parameters  %%%%
        
        %%%%  Static Environment Setting  %%%%
        stations
        railways
        %%%%  Static Environment Setting  %%%%
        
        %%%%  Dynamic Environment Setting  %%%%
        trains
        trainNum
        %%%%  Dynamic Environment Setting  %%%%
    end
    
    methods
        function obj = Environment(inputPath, Controller)
            %%%%    Environment constructor
            %    Initialize the stations and the railways
            obj.stations = cell(obj.stationNum, 1);
            obj.railways = cell(obj.railwayNum, 1);
            prevStation = 'start';
            for i = 1:obj.stationNum
                if i == obj.stationNum
                    nextStation = 'terminal';
                else
                    nextStation = obj.stationNames{i+1};
                end
                obj.stations{i, 1} = Station(obj.stationNames{i}, prevStation, nextStation, obj.railNums(i), 0, 0, Controller);
                obj.railways{i, 1} = Railway(prevStation, obj.stationNames{i}, obj.railwayLengths(i));
                prevStation = obj.stationNames{i};
            end
            obj.railways{i+1, 1} = Railway(obj.stationNames{i}, 'terminal', obj.railwayLengths(i+1));
            
            %    Initialize the trains
            globalTrainID = 1;
            obj.trains = [];
            input = fopen(inputPath);
            while ~feof(input)
                line = fgetl(input);
                trainInfo = strsplit(line, ' ');
                trainName = char(trainInfo(1));
                trainType = trainName(1);
                startTime = str2num(char(trainInfo(2)));
                S1ArrivalTime = obj.getTime(char(trainInfo(3)));
                S1LeaveTime = obj.getTime(char(trainInfo(4)));
                S2ArrivalTime = obj.getTime(char(trainInfo(5)));
                S2LeaveTime = obj.getTime(char(trainInfo(6)));
                S3ArrivalTime = obj.getTime(char(trainInfo(7)));
                S3LeaveTime = obj.getTime(char(trainInfo(8)));
                S4ArrivalTime = obj.getTime(char(trainInfo(9)));
                S4LeaveTime = obj.getTime(char(trainInfo(10)));
                S5ArrivalTime = obj.getTime(char(trainInfo(11)));
                S5LeaveTime = obj.getTime(char(trainInfo(12)));
                termiArrivalTime = str2num(char(trainInfo(13)));
                newTrain = Train(globalTrainID, trainName, startTime, S1ArrivalTime, S1LeaveTime, ...
                                 S2ArrivalTime, S2LeaveTime, S3ArrivalTime, S3LeaveTime, S4ArrivalTime, ...
                                 S4LeaveTime, S5ArrivalTime, S5LeaveTime, termiArrivalTime, obj.distBase, obj, Controller);
                obj.trains = [obj.trains;newTrain];
                globalTrainID = globalTrainID + 1;
            end
            obj.trains = Controller.sortByType(obj.trains);
            obj.trainNum = length(obj.trains);
            
        end
                
        function allFinish = updateState(obj, time, period)
            %    Update the state of stations
            for i=1:obj.stationNum
                obj.stations{i}.updateState(period);
            end
            %    Update the state of trains
            allFinish = 0;
            for i=1:obj.trainNum
                finish = obj.trains(i).updateState(time, period);
                allFinish = allFinish + finish;
            end
            if allFinish == obj.trainNum
                allFinish = 1;
            else
                allFinish = 0;
            end
        end
        
        function time = getTime(~, inputInfo)    %  helper function
        %    Return the valid time value for train schedule.
            if inputInfo == '-'
                time = -1;
            else
                time = str2num(inputInfo);
            end
        end
        
        function position = getStationPosition(obj, name)    %  helper function
        %    Return the position of the station
            if name == 'S1'
                position = obj.layout(1);
            elseif name == 'S2'
                position = obj.layout(2);
            elseif name == 'S3'
                position = obj.layout(3);
            elseif name == 'S4'
                position = obj.layout(4);
            elseif name == 'S5'
                position = obj.layout(5);
            elseif name == 'Termi'
                position = obj.layout(6);
            else 
                position = -1;
            end
        end
        
    end
end

