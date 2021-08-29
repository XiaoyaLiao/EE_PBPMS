function Pop = Selection(AlgParams, Pop, Upop) 

for ii = 1:AlgParams.PopSize
   if  Upop(ii).Obj < Pop(ii).Obj
       Pop(ii) = Upop(ii) ;
   end   
end