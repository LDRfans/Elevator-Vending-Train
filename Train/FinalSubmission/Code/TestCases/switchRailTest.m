function switchRailTest(tc)
    %    test switch rail function
    tc.press(tc.display.LoadInitialScheduleButton);
    pause(5);
    tc.press(tc.display.BeginSimulateButton);
    pause(30);
    tc.press(tc.display.S1In1);
    pause(5);
    tc.press(tc.display.S1Out2);
end

