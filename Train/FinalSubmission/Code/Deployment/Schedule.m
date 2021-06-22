classdef Schedule < handle
    %    schedule class
    
    properties
        StartLeaveTime
        S1ArrivalTime
        S1LeaveTime
        S2ArrivalTime
        S2LeaveTime
        S3ArrivalTime
        S3LeaveTime
        S4ArrivalTime
        S4LeaveTime
        S5ArrivalTime
        S5LeaveTime
        TermiArrivalTime
    end
    
    methods
        function obj = Schedule(startLeaveTime, S1ArrivalTime, S1LeaveTime, S2ArrivalTime, S2LeaveTime, S3ArrivalTime, ...
                                S3LeaveTime, S4ArrivalTime, S4LeaveTime, S5ArrivalTime, S5LeaveTime, termiArrivalTime)
            %    schedule constructor
            obj.StartLeaveTime = startLeaveTime;
            obj.S1ArrivalTime = S1ArrivalTime;
            obj.S1LeaveTime = S1LeaveTime;
            obj.S2ArrivalTime = S2ArrivalTime;
            obj.S2LeaveTime = S2LeaveTime;
            obj.S3ArrivalTime = S3ArrivalTime;
            obj.S3LeaveTime = S3LeaveTime;
            obj.S4ArrivalTime = S4ArrivalTime;
            obj.S4LeaveTime = S4LeaveTime;
            obj.S5ArrivalTime = S5ArrivalTime;
            obj.S5LeaveTime = S5LeaveTime;
            obj.TermiArrivalTime = termiArrivalTime;
        end
    end
end

