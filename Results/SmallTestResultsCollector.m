
%% For TS

Table_of_Results = zeros(36,3);

for test = 1:36
   
%     fName = ['Sol_S',num2str(test)];
    fName = ['SolNoFM_S',num2str(test)];
    load(fName)
    
    fName2 = ['S',num2str(test)];
    load(fName2)
    
    num2str(sum(BestFeasible.mObj(:)))
    
    addpath('C:\Users\c3273242\OneDrive - The University Of Newcastle\1 PhD\1 Thesis\5 Energy Efficient Parallel Machine\Codes\TS')

    [TWT, TEC] = VariableShow(BestFeasible,Pr);
    Table_of_Results(test,1) = sum(BestFeasible.mObj(:));
    Table_of_Results(test,2) = TWT;
    Table_of_Results(test,3) = TEC;
end


%% for SA



