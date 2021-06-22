function SetInit(tc)

    while tc.hElevators(1).moving_direction ~= 0 || tc.hElevators(2).moving_direction ~= 0
        pause(1)
    end
    
    while isempty(tc.hElevators(1).moving_up_queue) == 0 || isempty(tc.hElevators(1).moving_down_queue) == 0 ...
            || isempty(tc.hElevators(2).moving_up_queue) == 0 || isempty(tc.hElevators(2).moving_down_queue) == 0
        pause(1)
    end
    
    while tc.hElevators(1).door_open ~= 0 || tc.hElevators(2).door_open ~= 0
        pause(1)
    end

    tc.press(tc.hElevators(1).hCarUI.F1_0);
    tc.press(tc.hElevators(2).hCarUI.F1_0);
    
    while tc.hElevators(1).moving_direction ~= 0 || tc.hElevators(2).moving_direction ~= 0
        pause(1)
    end
    
    while isempty(tc.hElevators(1).moving_up_queue) == 0 || isempty(tc.hElevators(1).moving_down_queue) == 0 ...
            || isempty(tc.hElevators(2).moving_up_queue) == 0 || isempty(tc.hElevators(2).moving_down_queue) == 0
        pause(1)
    end
    
    while tc.hElevators(1).door_open ~= 0 || tc.hElevators(2).door_open ~= 0
        pause(1)
    end
    
end