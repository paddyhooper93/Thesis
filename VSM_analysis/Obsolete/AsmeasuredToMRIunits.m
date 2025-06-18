chi_emuPerTesla = [-1.89e-4 3.90e-5 7.41e-5 6.74e-4 6.47e-4 7.28e-4];
chi_ppm = zeros(size(chi_emuPerTesla));
chi_ppmLiterpermole_1 = zeros(1,3);
chi_ppmLiterpermole_2 = zeros(1,3);

for idx = 1:length(chi_emuPerTesla)
    emuToAmperesMeterSquared = 1e-3;
    teslaToAmperepermeter = 10^7 / (4*pi);
    cmcubedToMetercubed = 1e-6;
    Volume_cmcubed = (pi* (0.56/2)^2 * (2-0.56+1.57) - pi*(0.417/2)^2 *(1.32));
    Volume_mcubed = Volume_cmcubed * cmcubedToMetercubed;
    ppm = 1e6;
    chi_ppm(idx) = chi_emuPerTesla(idx) * emuToAmperesMeterSquared / teslaToAmperepermeter / Volume_mcubed * ppm;
    if idx ~= 1
        chi_ppm(idx) = chi_ppm(idx) - chi_ppm(1);
    end
    if idx == 4
        c_mol = 1.8; % mol/L
        MW = 110.98; % g/mol
        x_mol = 1; % [CaCl2] formula unit
    elseif idx == 5 || idx == 6
        c_mol = 10.21; % mmol/L
        MW = 55.845; % g/mol
        x_mol = 1; % [Fe] formula unit
    end
    if idx == 4 || idx == 5 || idx == 6
        chi_ppmLiterpermole_1(idx-3) = chi_ppm(idx) / c_mol;
        mass = 3.8e-3;
        chi_ppmLiterpermole_2(idx-3) = chi_emuPerTesla(idx) * emuToAmperesMeterSquared / teslaToAmperepermeter * ppm * MW / mass / x_mol;
    end
end