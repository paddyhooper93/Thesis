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
    Volume_KelF_cmcubed = pi*( (0.56/2)^2 * (2-0.56+1.57) ); % - (0.417/2)^2 *(1.32)    
    rho_kelF = 2.13; % g/cm^3
    mass_KelF = Volume_KelF_cmcubed * rho_kelF; % 3.8 g
    sigma_emu = sqrt(21)*(2e-6 + 5*5e-7); % emu
    emuToAmperesMeterSquared = 1e-3;     
    Volume_KelF = Volume_KelF_cmcubed;
    Volume_Straw = pi * ( 0.6 / 2 )^2 * (3.0);
    teslaToAmperepermeter = 10^7 / (4*pi);
    B0 = 5 * teslaToAmperepermeter;
    V_Sphere = 4/3*pi*(0.5/2)^3;
    % sigma_Aperm = sigma_emu * emuToAmperesMeterSquared / (Volume_KelF * cmcubedToMetercubed) *1e6;
    sigma_ppm = sigma_emu * emuToAmperesMeterSquared / (V_Sphere * cmcubedToMetercubed) / B0 * 1e6;
    % sigma_ppm_2 = sigma_emu * emuToAmperesMeterSquared / (Volume_Straw * cmcubedToMetercubed) / B0 * 1e6;

    %% NIST SRM 2853
    muperkg = 27.6; %Am^2/kg
    mass_kg = 2.8*1e-6; % kg
    mu = muperkg * mass_kg; % Am^2
    V_mmcubed = 4/3*pi*(1/2)^3;
    V_meterCubed = V_mmcubed * 1e-9;
    M = mu / V_meterCubed; % A/m
    teslaToAmperepermeter = 10^7 / (4*pi);
    B0 = 5 * teslaToAmperepermeter; % A/m
    chi = M / B0 * 1e6;

 
    %%

chi_ppm = zeros(length(i),1);
remanence = zeros(length(i),1);
coercivity = zeros(length(i),1);
chi_molar = zeros(2,1);
chi_ppm_cor = zeros(2,1);
p_a0 = zeros(length(i),1);
p_a1 = zeros(length(i),1);


x = 0;
for y = i
    fn_load = fullfile(dir_vsm, y{1});
    A = importdata(fn_load);
    emuToAmperesMeterSquared = 1e-3;        
    moment = A.data(:,3);
    x = x + 1;
    if x == 1 || x == 3 || x == 4 
        magnetization_SI = moment .* emuToAmperesMeterSquared ./ (Volume_KelF * cmcubedToMetercubed); % A/m
    else
        magnetization_SI = moment .* emuToAmperesMeterSquared ./ (Volume_Straw * cmcubedToMetercubed);
    end
    

    if x == 1
        B_Tesla = A.data(:,4); % B_digital (Tesla)
        % B_analog = A.data(:,5); % B_analog (Tesla)
        T_sample = A.data(:,2); % T_sample (Kelvin)
        % T_VTI = A.data(:,1); % T_VTI (Kelvin)
    else
        B_Tesla = A.data(:,1); % B_digital (Tesla)
        % sigma_vsm = sqrt(21)*(2e-6 + B_Tesla*5e-7); % emu

        % B_analog = A.data(:,2); % B_analog (Tesla)
        T_sample = A.data(:,5); % T_sample (Kelvin)
        % T_VTI = A.data(:,4); % T_VTI (Kelvin)
    end

    %% Applied field (T) versus magnetic moment (emu)
    % momentScale = 1e3; % Scale moment to 1e-3 emu units
    figure(x);

    teslaToAmperepermeter = 10^7 / (4*pi);
    B_SI = B_Tesla * teslaToAmperepermeter; % A/m

    scatter(B_SI, magnetization_SI , 18 , "black" , "filled" , "o"); %moment.*momentScale

    if x == 1% || x == 4
        xlim(1e6.*[0 4]);
        xticks(1e6.*[0 2 4]);
    else
        xlim(1e6.*[-4 4]);
        xticks(1e6.*[-4 -2 0 2 4]);
    end
    xticklabels(compose("%1.0e", xticks));
    ylim([-5 5]);
    yticks([-4 -2 0 2 4]);
    yticklabels(compose("%1.0e", yticks));
    xlabel('field (A/m)');
    ylabel('magnetization (A/m)')

    mdl_SI = fitlm(B_SI, magnetization_SI);
    chi_ppm(x) = mdl_SI.Coefficients{2,1}*1e6; 

    if x == 3 || x == 4
        chi_ppm_cor(x) = chi_ppm(x) - chi_ppm(1);
    end

    mdl_cgs = fitlm(B_Tesla, moment/Volume_KelF);
    remanence(x) = mdl_SI.Coefficients{1,1};
    coercivity(x) = -mdl_SI.Coefficients{1,1} / mdl_SI.Coefficients{2,1};
    fprintf('\n susceptibility: %.3f ppm, \n remanence: %.2f A/m, \n coercivity: %.2f A/m \n', chi_ppm(x), remanence(x), coercivity(x));   
    p_a0(x) = mdl_SI.Coefficients{1,4};
    p_a1(x) = mdl_SI.Coefficients{2,4};
    fprintf('\n p(a0)= %.2f \n p(a1) = %.2f \n', p_a0(x), p_a1(x));

    if x == 4 || x == 5
        chi_molar(x) = chi_ppm(x)/10.21;
        fprintf('\n molar susceptibility: %.2e ppm.L/mmol \n', chi_molar(x));
    end

    if x == 4
        chi_molar_cor = chi_ppm_cor(x)/10.21;
    end


    %% Applied field (T) versus sample temperature (K)
    
    % figure(x+5)
    % scatter(B_Tesla,T_sample,18,"black","filled","o");
    % if x == 1% || x == 4
    %     xlim([0 5])
    %     xticks([0 2 4]);
    % else
    %     xlim([-5 5]);
    %     xticks([-4 -2 0 2 4]);
    % end
    % xlabel('field (A/m)');
    % ylabel('temperature (K)');
    % ylim([280 300]);
    % yticks( [283 288 293 298] );
    % yticklabels(compose("%d", yticks));
    % 
    % mdl = fitlm(B_Tesla, T_sample);
    % fprintf('\n Temperature: y = %3.1f K + %3.1f K/T \n', mdl.Coefficients{1,1}, mdl.Coefficients{2,1});
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