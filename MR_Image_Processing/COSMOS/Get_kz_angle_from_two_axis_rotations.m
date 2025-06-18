clc
clear

% 7 T
% angle_x = str2double({'-36', '9', '14', '17', '12', '42'});
% angle_y = str2double({'-2', '18', '-26', '-22', '21', '-6'});

% 3 T
% angle_x = str2double({'-7', '4', '-40', '2', '-3', '-7'});
% angle_y = str2double({'37', '129', '3', '0', '2', '-5'});

% Wharton et al., 2010
% angle_x = str2double({'20', '-10', '-10'});
% angle_y = str2double({'0', '17', '-17'});

% 3 T_Test_Rot6_as_N -> leads to angle_z = [42, 38]
% angle_x = [0 -37];
% angle_y = [42 8];

% 3T_Test_Rot3_as_N -> leads to angle_z = 49, 37
% angle_x = [37 37];
% angle_y = [34 -5];

% % 3T_Rot4 as Neutral -> leads to angle_z = 2, 38, 51, 42, 5, 10 
% angle_x = [-2 -9 -2 -42 -5 -9];
% angle_y = [0 37 -51 3 2 -5];

% 3T_Rot5 as Neutral (Skip 3T_Rot2) -> leads to angle_z = 4, 35, 37, 5, 8
angle_x = [ 3  -6 -37 5 -4];
angle_y = [ -2 35  1 -2 -7];


angle_z = zeros(size(angle_x));

for i = 1:length(angle_x)
    [ angle_z(i) ] = kz_angle_from_two_axis_rotations(angle_x(i), angle_y(i));
end

clear angle_x angle_y i

% for i = 1:length(angle_x)
%     angle_z(i) = calculate_kz_angle(angle_x(i), angle_y(i));
% end
