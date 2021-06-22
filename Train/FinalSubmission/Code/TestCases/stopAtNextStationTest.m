function result = stopAtNextStationTest(tc)
    %    test stop at next station function
    result = 0;
    press = 0;
    tc.press(tc.display.LoadInitialScheduleButton);
    pause(5);
    tc.press(tc.display.BeginSimulateButton);
    pause(30);
    trainList = tc.environment.trains;
    while press == 0
        for i=1:tc.environment.trainNum
            train = trainList(i);
            if train.nextDest ~= train.nextStation
                tc.press(train.panel.StopatnextstationButton);
                press = 1;
                break
            end
        end
    end
end

