function h = scatterplot(m, s, varargin)

h = plot(m, s.^2, 'x', 'Color', [0.5 0.5 0.5]);
xlabel('Intensity');
ylabel('Variance');
title('Scatter plot');
if length(varargin) > 1
    range = varargin{1};
    xlim([min(range) max(range)]);
    hold all
    for k = 2:length(varargin)
        h(k) = plot(range, varargin{k}(range));
    end
end

if nargout == 0
    clear h;
end
