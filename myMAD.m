function y = myMAD(x,flag,dim)
%MAD Mean/median absolute deviation. MATLAB function.

%   References:
%      [1] L. Sachs, "Applied Statistics: A Handbook of Techniques",
%      Springer-Verlag, 1984, page 253.

%   Copyright 1993-2018 The MathWorks, Inc.


if nargin < 2 || isempty(flag)
    flag = 0;
end

% Validate flag
if ~(isequal(flag,0) || isequal(flag,1) || isempty(flag))
    error(message('stats:trimmean:BadFlagReduction'));
end

if nargin < 3 || isempty(dim)
    % The output size for [] is a special case, handle it here.
    if isequal(x,[]), y = nan('like',x); return; end

    % Figure out which dimension nanmean will work along.
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
end

if flag
    % Compute the median of the absolute deviations from the median.
%     y = nanmedian(abs(x - nanmedian(x,dim)),dim);
    y = median(abs(x - median(x,'omitnan')),'omitnan');

else
    % Compute the mean of the absolute deviations from the mean.
%     y = nanmean(abs(x - nanmean(x,dim)),dim);
    y = mean(abs(x - mean(x,'omitnan')),'omitnan');

end
end
