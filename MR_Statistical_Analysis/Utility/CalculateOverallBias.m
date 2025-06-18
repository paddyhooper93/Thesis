function [Beta_Idv, Beta_Hat, Beta_Hat_CIs] = CalculateOverallBias(Y_OverL,REF)
    
    % Beta_Idv         = (Y_OverL-(REF))./(REF).*100;
    Beta_Idv         = 100.*((abs(Y_OverL) - abs(REF))./abs(REF));
    % 
    N                = size(Y_OverL,1);
    Beta_Hat         = sum(Beta_Idv,1)/N;

    Var_Beta_Hat     = (sum(abs(Beta_Idv - Beta_Hat),1).^2)/(N-1);
    SEM              = sqrt(Var_Beta_Hat/N);
    Beta_Hat_CIs     = tinv(0.025,N-1)*SEM*-1;    
    Beta_Idv         = transpose([min(Beta_Idv) median(Beta_Idv) max(Beta_Idv)]);

    % Append an extra zero to the matrix for those material groups 
    % with only 4 concentrations

end