function [RDF] = CalculateRESHARP(iFreq, RDFMask, QSMMask, matrix_size, voxel_size)

        radius          = 4;
        alpha           = 0.01;
        refine_order    = 4;
        RDF             = RESHARP(iFreq, RDFMask, matrix_size, voxel_size, radius, alpha);
        RDF             = RDF .* QSMMask;
        [~, RDF, ~]     = PolyFit(double(RDF), QSMMask, refine_order);
       
end 