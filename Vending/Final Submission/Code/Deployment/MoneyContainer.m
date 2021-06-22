classdef MoneyContainer < handle
    properties
       cash1rmb
       cash5rmb
       coinHalfrmb
       coin1rmb
       allMoney
       max
    end
    
    methods 
        function obj = MoneyContainer()
           % initialize with 0's
           obj.cash1rmb = 0;
           obj.cash5rmb = 0;
           obj.coinHalfrmb = 0;
           obj.coin1rmb = 0;
           % obj.allContainers = [obj.cash1rmb, obj.cash5rmb, obj.coinHalfrmb, obj.coin1rmb];
           obj.max = [1000, 1000, 1000, 1000];
        end  
    end
end