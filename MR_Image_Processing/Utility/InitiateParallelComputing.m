function InitiateParallelComputing()
pool = gcp('nocreate');
if isempty(pool)
    % Optimize for laptop with 8 physical cores
    parpool('local', 8);
    % Test for parallel functionality
    parfor i = 1:8
        fprintf('Task %d executed on worker %d\n', i, getCurrentTask().ID);
    end
    diary on; % View Worker Logs: Useful for debugging errors
    disp('Parallel pool started.');
else
    disp('Parallel pool is already running.');
end