function [MeanStruct] = ObtainMeanStruct(S, num_orient, orient_init)

if nargin < 3
    orient_init = 1;
end

orientNames = fieldnames(S);
% num_orient = numel(orientNames);

subfieldNames = fieldnames(S.(orientNames{1}));

MeanStruct = struct();

for i = 1:numel(subfieldNames)
    subfieldName = subfieldNames{i};
    values = zeros(1, num_orient);
    for j = orient_init:num_orient
        values(j) = S.(orientNames{j}).(subfieldName);
    end
    MeanStruct.(subfieldName) = mean(values);
end