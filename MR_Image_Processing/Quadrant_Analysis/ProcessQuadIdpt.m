function [QuadOut] = ProcessQuadIdpt(dataset, Vol) % , hdr
% hdr.j is parsed externally as a for loop.

if contains(dataset, "3T") || contains(dataset, "TE1to7")
    fsname = '3T';
    OS = 0; % Oversample past the quadrant center to ensure vials are at least 10 mm away from mask edge
elseif contains(dataset, "7T") || contains(dataset, "TE1to3")
    fsname = '7T';
    OS = 0; % Oversample past the quadrant center to ensure vials are at least 15vox*0.7vox/mm=~10mm away from mask edge
end

QuadOut = cell(1,4);
QuadOut{1} = single(ProcessQuad1Idpt(fsname, Vol, OS));
QuadOut{2} = single(ProcessQuad2Idpt(fsname, Vol, OS));
QuadOut{3} = single(ProcessQuad3Idpt(fsname, Vol, OS));
QuadOut{4} = single(ProcessQuad4Idpt(fsname, Vol, OS));

% if ~isfield(hdr, 'j')
    % return
% elseif hdr.j == 1
    % [Quad1] = ProcessQuad1Idpt(fsname, Vol, OS);
% elseif hdr.j == 2
    % [Quad2] = ProcessQuad2Idpt(fsname, Vol, OS);
% elseif hdr.j == 3
    % [Quad3] = ProcessQuad3Idpt(fsname, Vol, OS);
% elseif hdr.j == 4
    % [Quad4] = ProcessQuad4Idpt(fsname, Vol, OS);
% end

end