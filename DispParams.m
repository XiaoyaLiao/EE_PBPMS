%% Display for CPLEX
clear
clc

load('S36');

disp('// Scale:')
disp(['int Nj=',num2str(Pr.Nj),';']);
disp(['int Nm=',num2str(Pr.Nm),';']);

disp('// Sets:')
disp('range job = 1..Nj ;')  
disp('range bch = 1..Nj ;') 
disp('range mch = 1..Nm ;') 

disp('// Parameters:')

% disp(['Nt=',num2str(Pr.Nt),';']);

% disp(['I=[',num2str(Pr.I),'];']);
% disp(['gama=[',num2str(Pr.gama),'];']);

fprintf('float P[job]=[')
for ii=1:numel(Pr.P)
    if ii < numel(Pr.P)
        fprintf('%d, ', Pr.P(ii));
    else
        fprintf('%d ', Pr.P(ii));
    end
end
fprintf('];\n')


fprintf('float R[job]=[')
for ii=1:numel(Pr.R)
    if ii < numel(Pr.R)
        fprintf('%d, ', Pr.R(ii));
    else
        fprintf('%d ', Pr.R(ii));
    end
end
fprintf('];\n')

fprintf('float d[job]=[')
for ii=1:numel(Pr.d)
    if ii < numel(Pr.d)
        fprintf('%d, ', Pr.d(ii));
    else
        fprintf('%d ', Pr.d(ii));
    end
end
fprintf('];\n')

fprintf('float w[job]=[')
for ii=1:numel(Pr.w)
    if ii < numel(Pr.w)
        fprintf('%d, ', Pr.w(ii));
    else
        fprintf('%d ', Pr.w(ii));
    end
end
fprintf('];\n')


fprintf('float alpha[job]=[')
for ii=1:numel(Pr.alpha)
    if ii < numel(Pr.alpha)
        fprintf('%d, ', Pr.alpha(ii));
    else
        fprintf('%d ', Pr.alpha(ii));
    end
end
fprintf('];\n')


fprintf('int b[job][job]=[');
for ii=1:size(Pr.b,1)
    if ii<size(Pr.b,1)
        fprintf('[')
        
        for jj=1:size(Pr.b,1)
            if jj < size(Pr.b,1)
                fprintf('%d, ', Pr.b(ii,jj));
            else
                fprintf('%d ', Pr.b(ii,jj));
            end
        end
        fprintf('],\n')
        
    else
         fprintf('[')
        
        for jj=1:size(Pr.b,1)
            if jj < size(Pr.b,1)
                fprintf('%d, ', Pr.b(ii,jj));
            else
                fprintf('%d ', Pr.b(ii,jj));
            end
        end
        fprintf(']];\n')
        
        
    end
end

fprintf('float B[mch]=[')
for ii=1:numel(Pr.B)
    if ii < numel(Pr.B)
        fprintf('%d, ', Pr.B(ii));
    else
        fprintf('%d ', Pr.B(ii));
    end
end
fprintf('];\n')


fprintf('float V[mch]=[')
for ii=1:numel(Pr.V)
    if ii < numel(Pr.V)
        fprintf('%d, ', Pr.V(ii));
    else
        fprintf('%d ', Pr.V(ii));
    end
end
fprintf('];\n')


% fprintf('float tau[mch]=[')
% for ii=1:numel(Pr.tau)
%     if ii < numel(Pr.tau)
%         fprintf('%d, ', Pr.tau(ii));
%     else
%         fprintf('%d ', Pr.tau(ii));
%     end
% end
% fprintf('];\n')

fprintf('float beta1[mch]=[')
for ii=1:numel(Pr.beta1)
    if ii < numel(Pr.beta1)
        fprintf('%d, ', Pr.beta1(ii));
    else
        fprintf('%d ', Pr.beta1(ii));
    end
end
fprintf('];\n')

fprintf('float beta2[mch]=[')
for ii=1:numel(Pr.beta2)
    if ii < numel(Pr.beta2)
        fprintf('%d, ', Pr.beta2(ii));
    else
        fprintf('%d ', Pr.beta2(ii));
    end
end
fprintf('];\n')

fprintf('float beta3[mch]=[')
for ii=1:numel(Pr.beta3)
    if ii < numel(Pr.beta3)
        fprintf('%d, ', Pr.beta3(ii));
    else
        fprintf('%d ', Pr.beta3(ii));
    end
end
fprintf('];\n')

disp(['float MaxTWT=',num2str(Pr.MaxTWT),';']);
disp(['float MaxTEC=',num2str(Pr.MaxTEC),';']);


disp('float L=1000;')


disp(['float lambda=' ,num2str(Pr.lambda),';']);
