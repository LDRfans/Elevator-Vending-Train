function status = IntegrationTest1(tc)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % A. User Purchase and its effect %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   a. Save value for checking
    product4_inventory = tc.vending.cellsSys.getInventory(4);
    cash5_amount = tc.vending.moneyProcessor.getMoneyAmount(2);
    coin1_amount = tc.vending.moneyProcessor.getMoneyAmount(4);
    %   b. Choosing product and cofirm
    tc.press(tc.userapp.IwantthisButton_4);
    tc.press(tc.userapp.ConfirmButton);
    %   c. Insert Money: cash5-cash5
    tc.press(tc.userapp.cash5);
    tc.press(tc.userapp.InsertCashButton);
    tc.press(tc.userapp.cash5);
    tc.press(tc.userapp.InsertCashButton);
    tc.press(tc.userapp.FinishInsertingButton);
    %   d. Fetch Change and product
    tc.press(tc.userapp.fetchallButton);
    %   A check: money container and cell system are updated correctly.
    statusA = isequal(tc.offlineapp.inventory4.Value, product4_inventory-1)&&... 
              isequal(tc.offlineapp.AmountEditField_4.Value, coin1_amount-1); 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % B. User Calls Maintainer and Maintainer's response %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tc.press(tc.userapp.CallMaintainerButton);
    tc.press(tc.offlineapp.FixButton);
    %  B check: light off
    statusB = isequal(tc.offlineapp.UserproblemLamp.Color, [0.8 0.8 0.8]) && ...
              isequal(tc.onlineapp.GetCalledbyUserLamp.Color, [0.8 0.8 0.8]);
    
    %%%%%%%%%%%%%%%
    % C: Maintain %
    %%%%%%%%%%%%%%%
    %   1. Fill Cell 2
    product2_inventory = tc.vending.cellsSys.getInventory(2);
    tc.type(tc.offlineapp.Replenish2, 50);
    tc.press(tc.offlineapp.FillButton_2);
    %   2. Empty Cell 1
    product1_inventory = tc.vending.cellsSys.getInventory(1);
    tc.type(tc.offlineapp.Withdraw1,100);
    tc.press(tc.offlineapp.FetchButton);
    %   3. Fill cash 1
    cash1_amount = tc.vending.moneyProcessor.getMoneyAmount(1);
    tc.type(tc.offlineapp.Replenish1_2,100);
    tc.press(tc.offlineapp.FillButton_5);
    %   4. Fetch coin 1
    coin1_amount = tc.vending.moneyProcessor.getMoneyAmount(4);
    tc.type(tc.offlineapp.Withdraw4_2,100);
    tc.press(tc.offlineapp.FetchButton_8);
    %   C check    
    statusC = isequal(tc.offlineapp.inventory2.Value, product2_inventory+50) && ...
              isequal(tc.offlineapp.inventory1.Value, product1_inventory-100) && ...
              isequal(tc.offlineapp.AmountEditField.Value, cash1_amount+100) && ...
              isequal(tc.offlineapp.AmountEditField_4.Value, coin1_amount-100);
              
    status = [statusA, statusB, statusC];
end

