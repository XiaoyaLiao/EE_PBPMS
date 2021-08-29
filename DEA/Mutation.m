function Vpop = Mutation(Pr, AlgParams, Pop) 


Vpop = Pop ;

for ii = 1:AlgParams.PopSize
    
    a = randi([1,AlgParams.PopSize],1,1);
    b = a ;
    while b == a || b == ii
        b = randi([1,AlgParams.PopSize],1,1);
    end
    c = a ;
    while c == a || c==b || c == ii
        c = randi([1,AlgParams.PopSize],1,1);
    end
    
    Mask = rand(1,Pr.Nj) ;
    Mask = Mask <= AlgParams.F ;
    
    RawSeq = Pop(a).Seq + Mask.*abs(Pop(b).Seq - Pop(c).Seq) ;
    RawSeq = rem(RawSeq,Pr.Nj) ;
    RawSeq(RawSeq==0) = Pr.Nj ;
    Vpop(ii).Seq = RawSeq ;
    
end





