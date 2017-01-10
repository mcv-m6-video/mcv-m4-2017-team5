# mcv-m4-2017-team5

WEEK 2
This week work performs foreground detection for the sequences that are placed at the /Database/Week02/ directory (highway, fall and traffic)


Task 1: Gaussian distribution

week2_task1_Gray

Input parameters: Sequence used (either highway, fall or traffic)

It computes foreground detection on the selected sequence using Gaussian modelling for several values of alpha. The evaluation is performed computing performance metrics as well as  Precision-Recall and ROC curves.

Task 2: Adaptative modelling

week2_task2_Gray.m

Input parameters: aplha, rho and the sequence used (either highway, fall or traffic)

It computes foreground detection on the selected sequence using adaptative modelling.
Then, grid search is performed to find the optimum values for rho and aplha. It computes the precision, recall and F-measure for a set of values for rho and alpha (the values between min_alpha, min_rho and max_alpha,max_rho)
The evaluation is finally performed using the optimum values.
A video is also generated to compare these results with the task 1 ones.


Task 3:


Task 4: Color extension

week2_task4_HSV.m and week2_task4_RGB.m

This task does the same as task 1 but using color sequences (on HSV and RGB colour spaces) instead of using gray scale ones.