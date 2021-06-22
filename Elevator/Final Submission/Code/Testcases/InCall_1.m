function InCall_1(tc)

    disp("InCall_1");

    % Elevator 1
    tc.press(tc.hElevators(1).hCarUI.F3_0);
    pause(1);
    tc.press(tc.hElevators(1).hCarUI.F2_0);
    pause(1);
    tc.press(tc.hElevators(1).hCarUI.F1_0);
    pause(1);
    
    % Elevator 2
    tc.press(tc.hElevators(2).hCarUI.F2_0);
    pause(1);
    tc.press(tc.hElevators(2).hCarUI.F1_0);
    pause(1);
    tc.press(tc.hElevators(2).hCarUI.FB_0);
    pause(1);
    
    
end