function [Phs_rs] = DICOM2Radians(Phs)
    % Similar to DICOM2Phase function in SEPIA toolbox
    if abs(max(Phs(:))-pi)>0.1 || abs(min(Phs(:))-(-pi))>0.1
        % allow small differences possibly due to data stype conversion or DICOM digitisation
        [min_phs, max_phs]  = bounds( Phs(:) , "all" );
        Phs_rs = 2*pi * ( Phs - min_phs ) / ( max_phs - min_phs ) - pi ;
    else
        Phs_rs = Phs;
    end
end