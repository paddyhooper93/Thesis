function expected_discrepancy = disc_principle(N_std, W, CF, M)
    %----------------------------------------------
    % Input args:
    %           N_std [rad/s] : output from fit_ppm_complex
    %           W [1]: weighting matrix
    %           B0 [T]: 3 or 7

    % Mask the inputs
    N_std = N_std .* M;
    W = W .* M;

    % Convert RDF from Hz to ppm
    % RDF_rads = 2 * pi * RDF; [rad/s]
    % RDF_ppm = RDF_rads / (gamma * B0); [ppm]

    % Convert noise std from rad/s to radians
    % N_std = N_std .* 3/1000; % [radians]

    % Convert from rad/s to ppm
    % / (gamma * B0)

    % Compute noise variance in ppm
    N_var = N_std.^2 ;

    % Compute expected noise
    expected_discrepancy = 1e6 / CF * sqrt( sum(W(:) .* W(:) .* N_var(:), "all" ) );
end