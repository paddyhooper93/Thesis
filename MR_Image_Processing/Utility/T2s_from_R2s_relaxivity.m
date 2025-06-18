function [T2s] = T2s_from_R2s_relaxivity(R2s_r, material)
if matches(material, 'uspio', IgnoreCase=true)
    c_mol= 1.25.*(10:5:30)./ 55.485;
    
elseif matches(material, 'ferritin', IgnoreCase=true)
    c_mol = (210 : 90 : 570) ./ 55.845;
    
elseif matches(material, 'chl', IgnoreCase=true)
    c_mol = (0.1:0.1:0.5)./110.98.*1000;
    
else
    c_mol = (0.1:0.1:0.5)./100.0869.*1000;
end

R2s=R2s_r.*c_mol; % s^-1
T2s=round(1000./R2s); % ms