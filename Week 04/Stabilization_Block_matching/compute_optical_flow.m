function flow_estimation = compute_optical_flow(frame1, frame2)
    [ni, nj, ~] = size(frame1);
    flow_estimation = zeros(ni, nj, 2);

    N = 16;
    P = 16;

    for i = 1:N:ni
        for j = 1:N:nj
            % For each block of the grid, we try to find the block on the other
            % image that has lower error
            Error = zeros((2*P + 1)*(2*P + 1), 3);
            n = 1;
            % The variable Error contains the value of the error and the values
            % for k and l with that error
            Block01 = frame1(i:min(i + N - 1, ni), j:min(j + N - 1, nj));
            N1 = min(i + N - 1, ni) - i;
            N2 = min(j + N - 1, nj) - j;
            for k = max(i - P, 1):min(i + P, ni - N)
                for l = max(j - P, 1):min(j + P, nj - N)
                    Block02 = frame2(k:min(k + N1, ni), l:min(l + N2,nj));
                    Error(n, 1) = sum(sum(abs(Block01 - Block02)));
                    % Vertical movement of the full block
                    Error(n, 2) = k - i;
                    % Horizontal movement of the full block
                    Error(n, 3) = l - j;
                    n = n + 1;
                end
            end
            %We only take on value with min error, the first one
            min_value = find(Error(:, 1) == min(Error(:, 1)), 1, 'first');
            flow_estimation(i:min(i + N, ni), j:min(j + N, nj), 1) = Error(min_value, 3);
            flow_estimation(i:min(i + N, ni), j:min(j + N, nj), 2) = Error(min_value, 2);
        end
    end
end

