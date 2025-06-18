function [filename, flag, FS, idx_dir, RDF, lambda, percentage]  = ...
    parse_paramOpt_input(varargin)

%flag = 'lam_CSF';
%FS = '7T';
idx_dir = 1;
filename = 'tmp_RDF.mat';
percentage = 0.3;

if size(varargin,2)>0
    for k=1:size(varargin,2)
        if strcmpi(varargin{k},'flag')
            flag=varargin{k+1};
        end
        if strcmpi(varargin{k},'FieldStrength')
            FS=varargin{k+1};
        end
        if strcmpi(varargin{k},'idx_dir')
            idx_dir=varargin{k+1};
        end
        if strcmpi(varargin{k},'filename')
            filename=varargin{k+1};
        end
        if strcmpi(varargin{k},'lambda')
            lambda=varargin{k+1};
        end
        if strcmpi(varargin{k},'percentage')
            percentage=varargin{k+1};
        end
    end
end

load(filename,'RDF');
