function EC = BatchECcal(Var,Pr,mm,bb) 

FirstIntrval = 1;

while Var.Sb{mm}(bb) >= Pr.I(FirstIntrval+1)
    FirstIntrval = FirstIntrval + 1 ;
end

nBatches = numel(Var.Cb{mm}) ;
eOpration = 0 ;
while true
    eOpration = eOpration + Pr.gama(FirstIntrval)*Pr.beta1(mm)* max(0, min(Pr.I(FirstIntrval+1),Var.Cb{mm}(bb)) - max(Var.Sb{mm}(bb),Pr.I(FirstIntrval))) ;
    
    if Var.Cb{mm}(bb) <= Pr.I(FirstIntrval+1)
        break
    else
        FirstIntrval = FirstIntrval + 1 ;
    end 
end

eBefore = 0;
if bb > 1
    FirstIntrval = 1;
    while Var.Cb{mm}(bb-1) >= Pr.I(FirstIntrval+1)
        FirstIntrval = FirstIntrval + 1 ;
    end
    
    
    while true
        
        eBefore = eBefore + Pr.gama(FirstIntrval)*Pr.beta2(mm)* max(0, min(Pr.I(FirstIntrval+1),Var.Sb{mm}(bb)) - max(Var.Cb{mm}(bb-1),Pr.I(FirstIntrval))) ; 

        if Var.Sb{mm}(bb) <= Pr.I(FirstIntrval+1)
            break
        else
            FirstIntrval = FirstIntrval + 1 ;
        end 
    end
end

eAfter = 0;
if bb < nBatches
    FirstIntrval = 1;
    while Var.Cb{mm}(bb) >= Pr.I(FirstIntrval+1)
        FirstIntrval = FirstIntrval + 1 ;
    end
    
    
    while true
        
        eAfter = eAfter + Pr.gama(FirstIntrval)*Pr.beta2(mm)* max(0, min(Pr.I(FirstIntrval+1),Var.Sb{mm}(bb+1)) - max(Var.Cb{mm}(bb),Pr.I(FirstIntrval))) ; 
        
        if Var.Sb{mm}(bb+1) <= Pr.I(FirstIntrval+1)
            break
        else
            FirstIntrval = FirstIntrval + 1 ;
        end 
    end
end


EC = eOpration + eAfter + eBefore ;