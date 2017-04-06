%% VEC - Matrix vectorization
% v=vec(A);

function v=vec(A);
[m n] = size(A);
v = reshape(A,m*n,1);
end