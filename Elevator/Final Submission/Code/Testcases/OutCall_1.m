function OutCall_1(tc)
    % T2.1.1: Floor Call with one Elevator
    disp("OusCall_1");

    tc.press(tc.hFloorUI(4).F1_down_0);
    pause(0.5);
    tc.press(tc.hFloorUI(3).F1_down_0);
    pause(0.5);
    tc.press(tc.hFloorUI(3).F1_up_0);
    
    while tc.hElevators(1).moving_direction ~= 0 || tc.hElevators(2).moving_direction ~= 0
        pause(1)
    end
    
    while isempty(tc.hElevators(1).moving_up_queue) == 0 || isempty(tc.hElevators(1).moving_down_queue) == 0 ...
            || isempty(tc.hElevators(2).moving_up_queue) == 0 || isempty(tc.hElevators(2).moving_down_queue) == 0
        pause(1)
    end
    
    
end