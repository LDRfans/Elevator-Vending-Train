classdef Purchase < handle    
    properties
        productID
        productPrice
        startChoosing
        finishChoosingProduct
        finishInsertingMoney
        remainChange
        getProduct
    end
    
    methods
        function obj = Purchase()
            obj.startChoosing = 0;
            obj.finishChoosingProduct = 0;
            obj.finishInsertingMoney = 0;
            obj.productID = -1; 
            obj.productPrice = 1e8;  
            obj.remainChange = -1;
            obj.getProduct = -1;
        end
        
                      
        function record = generateOneRecord(obj, inputMoney)
            % Statement T cover 1.4.1.1
            % ["Time Stamp" "Product ID" "Product Price" "Input Money" "Remain Change" "Get Product"]
            a = clock;
            timeStamp = a(2)*100000000 + a(3)*1000000 + a(4)*10000 +a(5)*100 + int64(a(6));
            record = [timeStamp, obj.productID, obj.productPrice, inputMoney, obj.remainChange, obj.getProduct];
        end
    end
end

