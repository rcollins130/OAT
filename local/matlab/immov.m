function immov(A, tdim)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

arguments
    A
    tdim = []
end

if isempty(tdim)
    tdim = ndims(A);
end

for ii_f=1:size(A,tdim)
    C = repmat({':'},1,ndims(A));
    C{tdim} = ii_f;
    imshow(A(C{:})); title(sprintf("%d",ii_f));
    pause(0.01)
end

end

