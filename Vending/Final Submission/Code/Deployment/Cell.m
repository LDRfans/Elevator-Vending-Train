classdef Cell < handle
    properties
        cid
        price
        inventory
        max
    end
    
    methods
        function obj=Cell(cid, price, inventory)
            obj.cid = cid;
            obj.price = price;
            obj.inventory = inventory;   
            obj.max = 100;
        end
    end
end