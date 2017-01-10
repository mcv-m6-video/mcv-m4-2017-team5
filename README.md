# mcv-m4-2017-team5

WEEK 2
This week work performs foreground detection for the sequences that are placed at the /Database/Week02/ directory (highway, fall and traffic)


Task 1: Gaussian distribution


Task 2: Adaptative modelling

Input parameters: aplha, rho and the sequence used (either highway, fall or traffic)

It computes foreground detection on the selected sequence using adaptative modelling.
Then, grid search is performed to find the optimum parameters for rho and aplha. It computes the precision, recall and F-measure for a set of values for rho and alpha (the values between min_alpha, min_rho and max_alpha,max_rho)
The evaluation is finally performed using the optimum values.
A video is also generated to compare these results with the task 1 ones.


Task 3:


Task 4: