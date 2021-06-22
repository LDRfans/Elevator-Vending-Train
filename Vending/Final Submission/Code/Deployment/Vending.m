classdef Vending < handle
   properties
       cellsSys
       userPanel
       maintainSys
       moneyProcessor
       logSys   
       %  
       maintainCode
       mistakeP
   end
   
   methods
       % Constructor
       function obj = Vending(maintainCode, mistakeP)
           obj.maintainCode = maintainCode;
           obj.mistakeP = max(min(mistakeP,1), 0); % set prob in [0,1]
           % initialize cell system. 
           obj.cellsSys = CellsSystem(2.5,100, 3,0, 5,100, 9,100); 
           obj.moneyProcessor = MoneyProcessor();
           % initialize money system. add some coins for change first.
           obj.moneyProcessor.updateContainer(0, 0, 1000, 500);
           
           % initialize panel.
           obj.userPanel = Panel();
           obj.userPanel.vending = obj;
           obj.userPanel.purchase = Purchase();
           
           %    don't allow for money insertion before choosing the product
           obj.userPanel.resetMoneyRegion();
           %    set button ability according to cell and money physically
           obj.updateUserPanelPhysically();
           obj.maintainSys = MaintainSys(); % initialize 2 panels
           obj.maintainSys.vending = obj;
           obj.logSys = obj.maintainSys.logSys;
           obj.maintainSys.offlinePanel.vending = obj;
           obj.maintainSys.onlinePanel.vending = obj;
           obj.updateOfflineMaintainPanel();
           obj.updateOnlineMaintainPanel(-1); % -1 means not updating log           
           if obj.maintainCode ~= 1
                obj.maintainSys.offlinePanel.panel.Enable = "off";
           end
           
       end
           
       % User Panel
       function updateUserPanelPhysically(obj)
           % Inventory part
           inventoryButton = [obj.userPanel.IwantthisButton, obj.userPanel.IwantthisButton_2, obj.userPanel.IwantthisButton_3, obj.userPanel.IwantthisButton_4];
           for i = 1:4
                if obj.cellsSys.getInventory(i) > 0
                    % branch T cover - 1.9.1.1
                    inventoryButton(i).Enable = "on";
                    eval("obj.userPanel.Lamp"+string(i)+".Color = [0 1 0]");
                else
                    % branch T cover - 1.9.1.2
                    inventoryButton(i).Enable = "off";
                    eval("obj.userPanel.Lamp"+string(i)+".Color = [1 0 0]");
                end                
           end
           % Money part
           moneyButton = [obj.userPanel.cash1, obj.userPanel.cash5, obj.userPanel.coinHalf, obj.userPanel.coin1];
           for i = 1:4
               if obj.moneyProcessor.getMoneyAmount(i) < 1000
                   % branch T cover - 1.9.1.3
                   moneyButton(i).Enable = "on";
               else
                   % branch T cover - 1.9.1.4
                   moneyButton(i).Enable = "off";
               end
           end
       end
       

       % Online Maintain Panel
       function updateOnlineMaintainPanel(obj, record)
           if ~isequal(-1,record)
               % branch T cover 1.9.2.1.1
               obj.logSys.addOneRecord(record);
               obj.logSys.refreshOnlinePanel();
           end
           % statement T cover 1.9.2.2.1
           obj.maintainSys.onlinePanel.updateCellLamp(obj.cellsSys.getInventory(1), obj.cellsSys.getInventory(2), ...
               obj.cellsSys.getInventory(3), obj.cellsSys.getInventory(4));
           obj.maintainSys.onlinePanel.updateMoneyLamp(obj.moneyProcessor.getMoneyAmount(1), obj.moneyProcessor.getMoneyAmount(2), ...
               obj.moneyProcessor.getMoneyAmount(3), obj.moneyProcessor.getMoneyAmount(4));
       end    
       
       % Offline Maintain Panel
       function updateOfflineMaintainPanel(obj)
           % statement T cover 1.9.3.1
           obj.maintainSys.offlinePanel.updateCellLamp(obj.cellsSys.getInventory(1), obj.cellsSys.getInventory(2), ...
               obj.cellsSys.getInventory(3), obj.cellsSys.getInventory(4));
           obj.maintainSys.offlinePanel.updateMoneyLamp(obj.moneyProcessor.getMoneyAmount(1), obj.moneyProcessor.getMoneyAmount(2), ...
               obj.moneyProcessor.getMoneyAmount(3), obj.moneyProcessor.getMoneyAmount(4));
       end
       
       function getUserProblem(obj)
            % statement T cover 1.9.4.1
           obj.maintainSys.offlinePanel.UserproblemLamp.Color = [1 0 0];
           obj.maintainSys.onlinePanel.GetCalledbyUserLamp.Color = [1 0 0];

       end
       
       function fixUserProblem(obj)
            % statement T cover 1.9.5.1
           obj.maintainSys.fixUserProblem();
           obj.userPanel.CellsPanel.Enable = "on";
           obj.userPanel.MoneyInputPanel.Enable = "on";
           obj.userPanel.DisplayRegionPanel.Enable = "on";
           obj.maintainSys.offlinePanel.UserproblemLamp.Color = [0.8 0.8 0.8];
           obj.maintainSys.onlinePanel.GetCalledbyUserLamp.Color = [0.8 0.8 0.8];
       end
       
       % What need to be done after finishing one purchase:
       function finishOnePurchase(obj, cid, dCash1, dCash5, dCoinHalf, dCoin1)
            % 0. update Cell (inventory) & Money Container
            if cid ~= -1
                % branch T cover 1.9.6.1.1
                obj.cellsSys.updateInventory(cid, -1);
            end
            % statement T cover 1.9.6.2.1
            obj.moneyProcessor.updateContainer(dCash1, dCash5, 0, 0);
                
            % 1. update online & offline maintain panel
            record = obj.userPanel.purchase.generateOneRecord(obj.userPanel.TotalmoneyinsertedEditField.Value);
            obj.updateOfflineMaintainPanel();
            obj.updateOnlineMaintainPanel(record);
           
            % 2. reset User Panel
            %   indicator according to physical amount
            obj.updateUserPanelPhysically();
            %   change & product output region reset
            obj.userPanel.resetOutputRegion();
            %   display region reset
            obj.userPanel.resetDisplayRegion();
            %   money input region reset
            obj.userPanel.resetMoneyRegion();
            %   set editable (look like at least)
            obj.userPanel.setYouChosePartEditability(1);
            obj.userPanel.setYouHaveInsertedPartEditability(1);
            % start a new purchase
            obj.userPanel.purchase = Purchase();            
       end
       

       
   end
    
end

