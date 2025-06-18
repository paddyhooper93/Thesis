%% TODO: Calculate the slope between 1 and 4 T (to get emu/T)
%% TODO: Subtract the KelF slope from the others.
%% CALCULATE: Coercivity & Remanence
clc
close all
clear
dir_vsm = 'C:\Users\rosly\Documents\VSM_RawData';
i = {'KelF.dat', ... 
    'Gel_straw.dat', 'Gel_KelF.dat', ...
    'Fe_KelF.dat', 'Fe_straw.dat'}; % 'Ca_persistent_KelF.dat', 

    
    % Figure 2-27, pp. 2-24 of VSM_Operation_Manual (7400, Lakeshore),
    % https://www.phys.sinica.edu.tw/~nanopublic/Operation%20Manual/VSM_Operation%20Manual/7400_Manual.pdf
    % Convert units in Figure 2-27 to mm (1cm = 10 mm)
    % Major diameter of #8-32 UNC thread: 4.166mm
    % Volume = Vol_{Outer cylinder} - Vol_{Threaded Rod Attachment}
    % i.e. volume of liquid sample holder + volume of sample space
    cmcubedToMetercubed = 1e-6;
    radius_B = 0.56/2;
    length_B = 2-0.56+1.57;
    Volume_B_cmcubed = pi*( (radius_B)^2 * (length_B) ); % - (0.417/2)^2 *(1.32)    
    rho_kelF = 2.13; % g/cm^3
    mass_KelF = Volume_B_cmcubed * rho_kelF; % 3.8 g
    % sigma_emu = sqrt(21)*(2e-6 + 5*5e-7); % emu
    sigma_emu = 1e-6;
    emuToAmperesMeterSquared = 1e-3;     
    Volume_B = Volume_B_cmcubed;
    radius_A = 0.6/2;
    length_A = 3.0;
    Volume_A = pi * ( radius_A )^2 * (length_A);
    teslaToAmperepermeter = 10^7 / (4*pi);
    B0 = 5 * teslaToAmperepermeter;
    N_B = (2 + (radius_B)/(sqrt(2)*(length_B/2)))^(-1);
    N_A = (2 + (radius_A)/(sqrt(2)*(length_A/2)))^(-1);
    N_d = mean([N_A,N_B]);
    

    % V_DopedGel = pi*(0.417/2)^2 * (1.47-0.6);
    % V_Holder = Volume_KelF - V_DopedGel;
    % m_DopedGel = 0.2;
    % m_Holder = 2;

    % chi_DopedGel = 0.782;
    % chi_Holder = -0.095;

    % chi_DopedGel_Holder = (chi_DopedGel * m_DopedGel + chi_Holder * m_Holder) / (m_DopedGel+m_Holder); 
    sigma_Amsquared = sigma_emu * emuToAmperesMeterSquared;
    sigma_Aperm_k = sigma_emu * emuToAmperesMeterSquared / (Volume_B * cmcubedToMetercubed);    
    sigma_ppb_k = sigma_emu * emuToAmperesMeterSquared / (Volume_B * cmcubedToMetercubed) / B0 * 1e9;
    sigma_Aperm_s = sigma_emu * emuToAmperesMeterSquared / (Volume_A * cmcubedToMetercubed);    
    sigma_ppb_s = sigma_emu * emuToAmperesMeterSquared / (Volume_A * cmcubedToMetercubed) / B0 * 1e9;
    sigma_ppb = (sigma_ppb_k+sigma_ppb_s)/2;
    sigma_Aperm = (sigma_Aperm_k+sigma_Aperm_s)/2;

    % sigma_ppm_2 = sigma_emu * emuToAmperesMeterSquared / (Volume_Straw * cmcubedToMetercubed) / B0 * 1e6;
    % (sigma_ppm+sigma_ppm_s)/2


    % sigma_emu1 = sqrt(21)*(2e-6); %emu
    % sigma_emuperT = sqrt(21)*(5e-7); % emu/T
    % sigma_ppm_mperA = sigma_emuperT * emuToAmperesMeterSquared / (Volume_KelF * cmcubedToMetercubed) / B0 * 1e6;
    
    

    %% NIST SRM 2853
    muperkg = 27.6; %Am^2/kg
    mass_kg = 2.8*1e-6; % kg
    mu = muperkg * mass_kg; % Am^2
    V_mmcubed = 4/3*pi*(1/2)^3;
    V_meterCubed = V_mmcubed * 1e-9;
    M = mu / V_meterCubed; % A/m
    teslaToAmperepermeter = 10^7 / (4*pi);
    B0 = 5 * teslaToAmperepermeter; % A/m
    chi = M / B0;
 
    %%

chi = zeros(length(i),1);
m = zeros(length(i),1);
m_cor = zeros(length(i),1);
SE_m = zeros(length(i),1);
b = zeros(length(i),1);
SE_b = zeros(length(i),1);
x_intercept = zeros(length(i),1);
SE_x = zeros(length(i),1);
Cov_bm = zeros(length(i),1);
chi_molar = zeros(2,1);
accuracy = zeros(3,1);
chi_ppm_cor = zeros(2,1);
p_a0 = zeros(length(i),1);
p_a1 = zeros(length(i),1);
T = zeros(length(i),1);
T_error = zeros(length(i),1);
T_field = zeros(length(i),1);
T_field_error = zeros(length(i),1);

%% TODO: Quantify the standard error of the x-intercept
%% TODO: Update the linear regression measurements for temperature


x = 0;
for y = i
    x = x + 1;
    fn_load = fullfile(dir_vsm, y{1});
    A = importdata(fn_load);
    emuToAmperesMeterSquared = 1e-3; 
    moment = A.data(:,3)*emuToAmperesMeterSquared;
    if x == 1
        B_Tesla = A.data(:,4); % B_digital (Tesla)
        T_sample = A.data(:,2); % T_sample (Kelvin)
    else
        B_Tesla = A.data(:,1); % B_digital (Tesla)
        T_sample = A.data(:,5); % T_sample (Kelvin)
        if x == 2 || x == 4 % Removing final third segment - maintaining consistency between acquisitions
            FinalThirdSegment = (1 : floor(2 * length(B_Tesla) / 3)); 
            moment = moment(FinalThirdSegment);
            B_Tesla = B_Tesla(FinalThirdSegment);
            T_sample = T_sample(FinalThirdSegment);
        end
    end
    if x == 1 || x == 2 || x == 4 
        magnetization_SI = moment ./ (Volume_B * cmcubedToMetercubed); % A/m
        magnetization_emupercmcubed = moment ./ Volume_B;
        ylimit = 5 ./ Volume_B;
    else
        magnetization_SI = moment ./ (Volume_A * cmcubedToMetercubed);
        magnetization_emupercmcubed = moment ./ Volume_A;
        ylimit = 5 ./ Volume_A;
    end

    



    %% Applied field (T) versus magnetic moment (emu)
    momentScale = 1e6; % Scale moment to 1e-6 Am^2 units
    figure(x);

    teslaToAmperepermeter = 10^7 / (4*pi);
    field_SI = B_Tesla * teslaToAmperepermeter; % A/m





    mdl_SI = fitlm(field_SI, magnetization_SI); % fieldScale.*field_SI
    m(x) = mdl_SI.Coefficients{2,1}.* 1e6; % ppm
    SE_m(x) = mdl_SI.Coefficients{2,2} .* 1e6; 
    field_cor = field_SI - N_d.*magnetization_SI;
    magnetization_cor = m(x) / (1 + m(x).*N_d).*field_SI;
    mdl_cor = fitlm(field_cor, magnetization_cor);
    m_cor(x) = mdl_cor.Coefficients{2,1};
    % SE_m_cor(x) = mdl_cor.Coefficients{2,2} .* 1e6;
    % m_cor(x) = (m(x)^(-1) - N_d)^(-1);

    if x == 3 || x == 4
        chi_ppm_cor(x) = m(x) - m(1);
    end

    b(x) = mdl_cor.Coefficients{1,1}; % A/m
    SE_b(x) = mdl_SI.Coefficients{1,2};
    x_intercept(x) = - b(x) / m(x); % 10^6.A/m
    covMatrix = mdl_SI.CoefficientCovariance;
    Cov_bm(x) = covMatrix(1,2); % Covariance between the intercept and slope
    SE_x(x) = sqrt( (SE_b(x)/m(x))^2 + (b(x)*SE_m(x) / m(x)^2)^2 - 2* m(x) * Cov_bm(x) / b(x) ^3 );
    fprintf('\n susceptibility: %.3f ppm, \n remanence: %.2f A/m, \n coercivity: %.2f 10^6 A/m \n', m_cor(x), b(x), x_intercept(x));   
    p_a0(x) = mdl_SI.Coefficients{1,4};
    p_a1(x) = mdl_SI.Coefficients{2,4};
    fprintf('\n p(a0)= %.2f \n p(a1) = %.2f \n', p_a0(x), p_a1(x));

    if x == 4 || x == 5
        chi_molar(x) = m_cor(x)/10.21;
        fprintf('\n molar susceptibility: %.2e ppm.L/mmol \n', chi_molar(x));
        if x == 4
            accuracy(x)= (m_cor(x) - 0.805);
            accuracy_pc(x)= (m_cor(x) - 0.805) / 0.805;
        else
            accuracy(x)= (m_cor(x) - 0.782);
            accuracy_pc(x)= (m_cor(x) - 0.782) / 0.782;
        end
    elseif x == 1
        accuracy = m_cor(x) - (-0.095);
        accuracy_pc = m_cor(x) - (-0.095) / 0.095;       
    end

    if x == 4
        chi_molar_cor = chi_ppm_cor(x)/10.21;
    end



    % Plot raw moment data (units shown on left y-axis)
yyaxis left
fieldScale = 1e-6;
plot(fieldScale.*field_SI, momentScale.*moment, '-k', 'LineWidth', 1.5);
ylabel('moment (10^{-6} Am^2)');
ylim([-5 5]);
yticks([-4 -2 0 2 4]);
        
mdl = fitlm(fieldScale.*field_SI, momentScale.*moment); 
linear_curve_momentvsT = mdl.Coefficients{2,1}.* fieldScale.*field_SI + mdl.Coefficients{1,1};    


hold on
p_regression = plot(fieldScale.*field_SI,linear_curve_momentvsT);
p_regression(1).LineStyle = '--';
p_regression(1).Color = "b";
pbaspect([1 1 1])
legend({'Raw data', 'Linear fit'}, 'Location', 'best'); 
hold off


% Plot magnetization units on right y-axis
yyaxis right
axis on;       
box on;        
set(gca, 'XColor', 'k', 'YColor', 'k'); 
set(gca, 'xtickmode', 'auto', 'ytickmode', 'auto'); 
ylabel('magnetization (A/m)');
ylim([-ylimit ylimit]);
yticks([-4 -2 0 2 4]);

% Common x-axis formatting
xlabel('field (10^6A/m)');

if x == 1
    xlim([0 4]);
    xticks([0 2 4]);
else
    xlim([-4 4]);
    xticks([-4 -2 0 2 4]);
end
xticklabels(compose("%1.0f", xticks));

    %% Applied field (T) versus sample temperature (K)
    % Analyse 0 -> 5 T
if x == 1
    divisor = 2;
else
    divisor = 4;

end
    % Plot Kelvin on the left y-axis
    yyaxis left
    figure(x+5)
    plot(fieldScale.*field_SI, T_sample, '-k', 'LineWidth', 1.5);
    ylabel('temperature (\circ K)');
    ylim([280 300]);
    yticks( [283 288 293 298] );
    yticklabels(compose("%d", yticks));

    hold on



    N = length(field_SI);
    N_new = floor(N / 4) * 4;
    field_SI = field_SI(1:N_new);
    T_sample = T_sample(1:N_new);


    fieldRange = 1:length(field_SI)/divisor;
    T_sample_segment = T_sample(fieldRange);
    field_SI_segment = field_SI(fieldRange);
    mdl = fitlm(fieldScale .* field_SI_segment, T_sample_segment);
    a0_term = mdl.Coefficients{1,1};
    a1_term(1) = mdl.Coefficients{2,1};
    a1_term_error(1) = mdl.Coefficients{2,2};
    linear_curve_HvsT = a1_term(1) .* fieldScale .* field_SI_segment + a0_term;
    p_regression(1) = plot(fieldScale .* field_SI_segment, linear_curve_HvsT);
    p_regression(1).LineStyle = '--';
    p_regression(1).Color = 'b';
    hold on

    for idx = 2:divisor
        fieldRange = (max(fieldRange) + 1) : (idx * length(field_SI)/divisor);
    T_sample_segment = T_sample(fieldRange);
    field_SI_segment = field_SI(fieldRange);
    mdl = fitlm(fieldScale .* field_SI_segment, T_sample_segment);
    a0_term = mdl.Coefficients{1,1};
    a1_term(idx) = mdl.Coefficients{2,1};
    a1_term_error(idx) = mdl.Coefficients{2,2};    
    linear_curve_HvsT(:,idx) = a1_term(idx) .* fieldScale .* field_SI_segment + a0_term;
    p_regression(:,idx) = plot(fieldScale .* field_SI_segment, linear_curve_HvsT(:,idx));
    p_regression(:,idx).LineStyle = '--';
    p_regression(:,idx).Color = 'b';
    hold on
    end
% Plot Celcius units on right y-axis
yyaxis right
axis on;       
box on;        
set(gca, 'XColor', 'k', 'YColor', 'k'); 
set(gca, 'xtickmode', 'auto', 'ytickmode', 'auto'); 
ylabel('temperature (\circ C)');
ylim([280 300] - 273.15);
yticks( [283 288 293 298] - 273.15 );
yticklabels(compose("%d", round(yticks)));    
    legend({'Raw data', 'Linear fit (of each branch)'}, 'Location', 'best'); % 'best' places it automatically
    % Common x-axis formatting
xlabel('field (10^6A/m)');

if x == 1
    xlim([0 4]);
    xticks([0 2 4]);
else
    xlim([-4 4]);
    xticks([-4 -2 0 2 4]);
end
xticklabels(compose("%1.0f", xticks));

    hold off


    % count = 1;
% field_SI_segment = zeros(floor(length(field_SI)/divisor),divisor);
% linear_curve_HvsT = zeros(floor(length(field_SI)/divisor),divisor);
% for i = 1:divisor
%     fieldRange.i = count:floor(length(field_SI)*i/divisor);
%     field_SI_segment(:,i) = field_SI(fieldRange.i);
%     T_sample_segment.i = T_sample(fieldRange.i);
%     mdl = fitlm(fieldScale.*field_SI_segment(:,i), T_sample_segment.i); 
%     a1.i = mdl.Coefficients{2,1}.* fieldScale.*field_SI_segment(:,i);
%     a0.i = mdl.Coefficients{1,1};
%     linear_curve_HvsT(:,i) = a1.i + a0.i;    
% 
%     p_regression(i) = plot(fieldScale.*field_SI_segment(:,i),linear_curve_HvsT(:,i));
%     p_regression(i).LineStyle = '--';
%     p_regression(i).Color = "b";
%     pbaspect([1 1 1])
%     hold on
%     count = count + N_new;
% end

    
    % T(x) = mdl.Coefficients{1,1};
    % T_error(x) = mdl.Coefficients{1,2};
    T(x) = mean(T_sample);
    T_error(x) = std(T_sample);
    T_field(x) = mean(a1_term);
    T_field_error(x) = mean(a1_term_error);
    % fprintf('\n Temperature: y = (%3.1f  pm %3.1f) K \n', T, T_error);
    % fprintf('\n Temperature: y = (%3.1f  pm %3.1f) K/T \n', T_field, T_field_error);
    % 
    % fprintf('\n p(a0)= %.2f \n p(a1) = %.2f \n', mdl.Coefficients{1,4}, mdl.Coefficients{2,4});


    %% Applied field (T) versus sensor phase (units unspecified)

    % phs = A.data(:,6); % sensor phase (units unspecified)  
    % figure(x+12)
    % scatter(B_digital,phs,18,"black","filled","o");
    % if x == 1 || x == 2
    %     xlim([0 5])
    %     xticks([0 2 4]);
    % else
    %     xlim([-5 5]);
    %     xticks([-4 -2 0 2 4]);
    % end
    % xlabel('B_{digital} (T)');
    % ylabel('Sensor phase (rad)')
    % ylim([-27.0 -26.0]);
    % yticks( [ -26.8 -26.5 -26.2 ] );
    % yticklabels(compose("%.3g", yticks));
    % 
    % mdl = fitlm(B_digital, phs);
    % fprintf('\n Sensor phase: y = %3.1f rad + %3.1f rad/T \n', mdl.Coefficients{1,1}, mdl.Coefficients{2,1});    

    %% Applied field (T) versus sensor amplitude (units unspecified)

    % ampl = A.data(:,7);  % sensor amplitude (units unspecified)
    % figure(x+18)
    % scatter(B_digital,ampl,18,"black","filled","o");
    % if x == 1 || x == 2
    %     xlim([0 5])
    %     xticks([0 2 4]);
    % else
    %     xlim([-5 5]);
    %     xticks([-4 -2 0 2 4]);
    % end
    % xlabel('B_{digital} (T)');
    % ylabel('Sensor amplitude (emu)')
    % ylim(1e-3.*[6.9 7.3]);
    % yticks( 1e-3.*[ 7.0 7.1 7.2 ] );
    % yticklabels(compose("%.2g", yticks));
    % 
    % mdl = fitlm(B_digital, ampl);
    % fprintf('\n Sensor amplitude: y = %.2e emu + %.2e emu/T \n', mdl.Coefficients{1,1}, mdl.Coefficients{2,1});        


end