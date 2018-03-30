function [aStruct] = ArrayOfStructs(varargin)
    assert(mod(nargin, 2) == 0, 'odd number of input arguments');
    avFields = reshape(varargin, 2, []);
    [m, ~] = cellfun(@size, avFields(2, :));
    assert(range(m) == 0, 'unmatching array size');
    avFields(3,:) = num2cell(m);

    aStruct = struct;

    for vField = avFields
        for i = 1:avFields{3}
            aStruct(i).(vField{1}) = vField{2}(i, :);
        end
    end
end