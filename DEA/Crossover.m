function Upop = Crossover(Pr, AlgParams, Pop, Vpop) 

Upop = Pop ;

for ii = 1:AlgParams.PopSize
   Mask = rand(1,Pr.Nj) ;
   Mask = Mask <= AlgParams.W ;
   
   Upop(ii).Seq = zeros(1,Pr.Nj);
   Upop(ii).Obj = inf ;
   
   Upop(ii).Seq = Mask.*Vpop(ii).Seq ;
   
   % Remove repeated jobs
   NonRepJobs = [] ;
   for jj = Pr.Nj:-1:1
       isNew = 1 ;
       for ll = 1:numel(NonRepJobs)
           if Upop(ii).Seq(jj) ==  NonRepJobs(ll) 
               isNew = 0 ;
               break
           end           
       end
       
       if isNew == 1 && Upop(ii).Seq(jj) ~= 0
           NonRepJobs = [NonRepJobs Upop(ii).Seq(jj)];
       else
           Upop(ii).Seq(jj) = 0 ;
       end  
   end
   
   
   % Fill empty positions by X(t-1)
   
   AbsentJobs = setdiff(1:Pr.Nj,NonRepJobs) ;
   Positoins = zeros(1,numel(AbsentJobs)) ;
   for ll = 1:numel(AbsentJobs)
       Positoins(ll) = find(Pop(ii).Seq == AbsentJobs(ll)) ;
   end
   [~, Ord] = sort(Positoins) ;
   AbsentJobs = AbsentJobs(Ord) ;
   
   Upop(ii).Seq(Upop(ii).Seq==0) = AbsentJobs ;
    
   Upop(ii) = ObjFunc(Pr,Upop(ii)); 
end

