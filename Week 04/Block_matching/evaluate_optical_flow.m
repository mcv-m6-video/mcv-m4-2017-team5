function [ MSE, PEPN ] = evaluate_optical_flow( params, Flow_est )

Flow_gt  = flow_read(params.directory_GT);

[MSE, PEPN] = flow_error(Flow_gt, Flow_est, params.tau);
end

