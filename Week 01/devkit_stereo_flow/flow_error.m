function [MSE, PEPN] = flow_error (F_gt, F_est, tau)
%Computes MSE and PEPN
[E, F_val] = flow_error_map (F_gt, F_est);
MSE = sum(E(:))/sum(F_val(:));
PEPN = length(find(E > tau))/length(find(F_val));
end