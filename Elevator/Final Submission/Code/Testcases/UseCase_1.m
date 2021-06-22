function UseCase_1(tc)
    % Demo test

    disp("UseCase_1");
    
    % Floor Calls
    tc.press(tc.hFloorUI(4).F1_down_0);
    pause(1);

    tc.press(tc.hFloorUI(3).F1_up_0);
    pause(1);
    tc.press(tc.hFloorUI(3).F1_down_0);
    pause(1);
    
    tc.press(tc.hFloorUI(1).F1_up_0);
    pause(1);

    % Elevator 1
    tc.press(tc.hElevators(1).hCarUI.F3_0);
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