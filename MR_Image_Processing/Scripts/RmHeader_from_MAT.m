
hdr.path_to_data = 'C:\Users\rosly\Documents\QSM_PH\Data\NC\';

i = {'7T_BL', '7T_BL_Rep', '7T_9mth', '7T_24mth', '7T_24mth_Rep', ...
     '3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep', ...
     'TE1to7_9mth', 'TE1to7_24mth', 'TE1to7_24mth_Rep', ...
     'TE1to3_9mth', 'TE1to3_24mth', 'TE1to3_24mth_Rep'};

for dataset = i

fileInfo = who('-file', dataset{1});
for i = 1:length(fileInfo)
    if isfield(fileInfo{i}, 'hdr')
        fileInfo{i} = rmfield(fileInfo{1}, 'hdr');
    end
end
fileInfo = fileInfo(~cellfun('isempty', fileInfo));

dataset_fn = strcat(dataset{1}, '.mat');
load(dataset_fn, fileInfo{:});
save(dataset_fn, fileInfo{:});
end