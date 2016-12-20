function [E, F_gt_val] = flow_error_map (F_gt,F_est)
%Computes matrix of errors
F_gt_du  = shiftdim(F_gt(:,:,1));
F_gt_dv  = shiftdim(F_gt(:,:,2));
F_gt_val = shiftdim(F_gt(:,:,3));

F_est_du = shiftdim(F_est(:,:,1));
F_est_dv = shiftdim(F_est(:,:,2));

E_du = F_gt_du - F_est_du;
E_dv = F_gt_dv - F_est_dv;
E    = sqrt(E_du.^2 + E_dv.^2);
%If the pixel is occluded, the value is wrong
E(F_gt_val == 0) = 0;
end