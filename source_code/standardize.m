function [X, mean_X, std_X] = standardize(varargin)
switch nargin
    case 1
        mean_X = mean(varargin{1});
        std_X = std(varargin{1});

        X = varargin{1} - repmat(mean_X, [size(varargin{1}, 1) 1]);

        for i = 1:size(X, 2)
            X(:, i) =  X(:, i) / std(X(:, i));
        end     
    case 3
        mean_X = varargin{2};
        std_X = varargin{3};
        X = varargin{1} - repmat(mean_X, [size(varargin{1}, 1) 1]);
        for i = 1:size(X, 2)
            X(:, i) =  X(:, i) / std_X(:, i);
        end 
end