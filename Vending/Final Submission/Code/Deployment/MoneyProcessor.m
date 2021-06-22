classdef MoneyProcessor < handle
    properties (Access = private)
        container
    end
    
    methods
        function obj = MoneyProcessor()
            obj.container = MoneyContainer();
        end
        
        function addCash1(obj)
            % Statement T cover  1.1.5.1 
           obj.container.cash1rmb = obj.container.cash1rmb + 1; 
        end
        
        function addCash5(obj)
            % Statement T cover  1.1.6.1 
           obj.container.cash5rmb = obj.container.cash5rmb + 1; 
        end
        
        function addCoinHalf(obj)
            % Statement T cover  1.1.7.1 
           obj.container.coinHalfrmb = obj.container.coinHalfrmb + 1; 
        end
        
        function addCoin1(obj)
            % Statement T cover  1.1.4.1 
           obj.container.coin1rmb = obj.container.coin1rmb + 1; 
        end

        function amount = getMoneyAmount(obj, moneyID)
            % 1 - cash 1r; 2 - cash 5r; 3 - coin 0.5r; 4 - coin 1r.
            if ismember([moneyID], [1 2 3 4])
                % Branch T cover 1.1.3.1
                switch(moneyID)
                    case 1
                        % Branch T cover 1.1.3.2
                        amount = obj.container.cash1rmb;
                    case 2
                        % Branch T cover 1.1.3.3
                        amount = obj.container.cash5rmb;
                    case 3
                        % Branch T cover 1.1.3.4
                        amount = obj.container.coinHalfrmb;
                    case 4
                        % Branch T cover 1.1.3.5
                        amount = obj.container.coin1rmb;
                end
            else
                % Branch T cover 1.1.3.6
                amount = "wrong";
            end
        end
        
        function status = updateContainer(obj, dCash1, dCash5, dCoinHalf, dCoin1)
            if obj.container.cash1rmb + dCash1 < 0 || obj.container.cash1rmb + dCash1 > obj.container.max(1) 
                % Branch T cover 1.1.2.1
                status1 = 0;
            else
                % Branch T cover 1.1.2.2
                status1 = 1;
                obj.container.cash1rmb = obj.container.cash1rmb + dCash1;
            end
            
            if obj.container.cash5rmb + dCash5 < 0 || obj.container.cash5rmb + dCash5 > obj.container.max(2)
                % Branch T cover 1.1.2.3
                status2 = 0;
            else
                % Branch T cover 1.1.2.4
                status2 = 1;
                obj.container.cash5rmb = obj.container.cash5rmb + dCash5;
            end
            
            if obj.container.coinHalfrmb + dCoinHalf < 0 || obj.container.coinHalfrmb + dCoinHalf > obj.container.max(3)
                % Branch T cover 1.1.2.5
                status3 = 0;
            else
                % Branch T cover 1.1.2.6
                status3 = 1;
                obj.container.coinHalfrmb = obj.container.coinHalfrmb + dCoinHalf;
            end
            
            if obj.container.coin1rmb + dCoin1 < 0 || obj.container.coin1rmb + dCoin1 > obj.container.max(4)
                % Branch T cover 1.1.2.7
                status4 = 0;
            else
                % Branch T cover 1.1.2.8
                status4 = 1;
                obj.container.coin1rmb = obj.container.coin1rmb + dCoin1;

            end
            status = [status1, status2, status3, status4];
        end
        
        % the program for deciding how to refund
        function v = refund(obj, price, moneyReceive)
            change = moneyReceive - price;
            mistake = 0;
            remainChange = 0;
            if obj.container.coin1rmb >= floor(change) && obj.container.coinHalfrmb >= (change - floor(change))/0.5 
                % Brance T Cover 1.1.1.1
                % cool in both cases
                coin1 = floor(change);
                coinHalf = (change - floor(change))/0.5;
            elseif obj.container.coin1rmb < floor(change) && obj.container.coinHalfrmb >= (change- obj.container.coin1rmb)/0.5
                % Brance T Cover 1.1.1.2
                % coin1 is not enough but coin 0.5 is enough to cover
                coin1 = obj.container.coin1rmb;
                coinHalf = (change-coin1)/0.5;   
            else 
                % Brance T Cover 1.1.1.3
                % coin 1 and coin 0.5 in total is not enough to cover
                coin1 =  obj.container.coin1rmb;
                coinHalf = obj.container.coinHalfrmb;
                remainChange = change - (coin1 + coinHalf*0.5);
                % this is for the failcase dealing: 
                % return [-1, remainChange, coinHalf, coin1].
                mistake = 1;
                % call maintainer and display sorry&how2callmaintainer info
            end
            if mistake ~= 1
                % Brance T Cover 1.1.1.4
                v = [coinHalf, coin1];  
            else 
                % Brance T Cover 1.1.1.5
                v = [-1, remainChange, coinHalf, coin1];
            end
            obj.container.coin1rmb = obj.container.coin1rmb - coin1;
            obj.container.coinHalfrmb = obj.container.coinHalfrmb - coinHalf;
        end
        
        
    end
        
end