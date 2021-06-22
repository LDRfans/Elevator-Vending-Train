classdef CellsSystem < handle
    properties (Access = private)
       cell1
       cell2
       cell3
       cell4
       cells
    end
    
    methods
        function obj=CellsSystem(price1, inventory1, price2, inventory2, price3, inventory3, price4, inventory4)
            obj.cell1 = Cell(1, price1, inventory1);
            obj.cell2 = Cell(2, price2, inventory2);
            obj.cell3 = Cell(3, price3, inventory3);
            obj.cell4 = Cell(4, price4, inventory4);
            obj.cells = [obj.cell1 obj.cell2 obj.cell3 obj.cell4];
        end
        
        function price=getPrice(obj, cid)
            % Statement T cover 1.2.1.1
            price = obj.cells(cid).price;
        end
            
        function inventory=getInventory(obj, cid)
            % Statement T cover 1.2.2.1
            inventory = obj.cells(cid).inventory;
        end
        
        function isEmpty=checkEmpty(obj, cid)
            % Statement T cover 1.2.3.1
            isEmpty = obj.cells(cid).inventory==0;
        end
        
        function status = updateInventory(obj, cid, dInventory) 
            if obj.cells(cid).inventory + dInventory < 0 || obj.cells(cid).inventory + dInventory > obj.cells(cid).max
                            % Branch T cover 1.2.4.1
                status = 0;
            else
                            % branch T cover 1.2.4.2
                obj.cells(cid).inventory = obj.cells(cid).inventory + dInventory;
                status = 1;
            end
        end
    end
end



















