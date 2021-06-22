function acceToCruSpeedTest(tc)
    %    test accelerate to cruising speed function
    press = 0;
    tc.press(tc.display.LoadInitialScheduleButton);
    pause(5);
    tc.press(tc.display.BeginSimulateButton);
    pause(30);
    trainList = tc.environment.trains;
    while press == 0
        for i=1:tc.environment.trainNum
            train = trainList(i);
            if train.state == 0
                tc.press(train.panel.AcceleratetocruisingspeedButton);
                press = 1;
                break
            end
        end
    end
end

