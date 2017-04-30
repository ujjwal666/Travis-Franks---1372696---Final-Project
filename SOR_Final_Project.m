%Travis Franks 1372696 Helmholtz Equation Final Project Gauss Seidel Method
clear all
clc
%Setting the value of X_Internal_Nodes, the number of elements along X-domain:
X_Internal_Nodes = input('Enter value of X_Internal_Nodes, the number of internal nodes for the X-domain: ');
%Setting the value of Y_Internal_Nodes, the number of elements along
%Y-domain:
Y_Internal_Nodes = input('Enter value of Y_Internal_Nodes, the number of internal nodes for the Y-domain: ');
%Setting the value of C (capital lambda in problem statement):
C = input('Enter value of C, the given constant for capital lambda: ');
%Setting the value of G (Overrelaxation variable):
G = input('Enter value of G, the lambda coefficient, to be between 1 and 2, to use for SOR (overrelaxation)');
%Setting the value of Es, the acceptable limit of error for system convergence:
Es = 10^-10;
%Defining L, the length of the X and Y domains:
L = 2 * pi();
%Determining DX and DY, the change of X and Y respectively from element to
%element:
DX = L / (X_Internal_Nodes + 1);
DY = L / (Y_Internal_Nodes + 1);
%Defining coefficients, A and B, that remain constant throughout matrix operations:
A = C - (2 * (DX^2)) - (2 * (DY^2));
B = (DX^2) * (DY^2);
%Determining number of elements  on both X and Y domains, so as to only
%perform the calculation one time for optimization:
N = X_Internal_Nodes + 2; %N = number of X domain values
M = Y_Internal_Nodes + 2; %M = number of Y domain values
%Performing setup for Gauss-Seidel Approximation that will solve for U values
%(unknown solution values over X and Y domains):
U = zeros(N,M);
W = zeros(N,M);
Z = 0; %Z functions as a counter for number of iterations performed during Gauss-Seidel
Error = zeros(N,M-2); %(M-2) rather than just M because the Dirichlet Boundary Conditions cause two rows to have constant values and therefore will have an error of 0 per iteration (optimal to exclude unnecessary repeated calculations) 
Ea = 100; %Provides initial value of Ea, or the relative iterative error, for the Gauss_Seidel Approximation
%Solving for U values defined by Dirichlet Boundary Conditions that will
%remain constant as Gauss Seidel iterations are performed:
for i = 1:N
    U(i,1) = cos(pi() * DX * (i-1)) * cosh((2 * pi()) - (DX * (i-1)));
    U(i,M) = ((i-1) * DX)^2 * sin(((i-1) * DX) / 4);
end
%Defining node indexing points to be used for the general form of the
%discretization:
NN = N-1;
MM = M-1;
%Defining initial Tcheck value for checkpointing every set period of time of
%the Gauss-Seidel loop:
Tcheck = 60; %checkpoint every 60 seconds
%Defining initial timer variable value to be greater than start timer initial value to start timer loop in Gauss-Seidel loop:
T = 0;
Tcounter = 0; %Stores time values for combined loop times, if loop takes less than a minute to run
save('Variables.mat') %Resets variable values before load checkpoint, so code can be run from either the start or load point
%%
%*****To load variables for checkpointing, run starting from this block*****
load('Variables.mat')
%Performing Gauss Seidel Approximation to solve for U values:
if (A ~= 0)%Set condition for just in case the variable coefficient is equal to zero from a poor choice in nodes along X and Y domains, as it will function as a denominator
    while (Ea > Es)
        tic;
        if (Tcounter >= Tcheck) %Saves at least every 60 seconds or every Gauss-Seidel loop iteration, if the iterations take longer
            Tcounter = 0; %Resets time counter to 0
            save('Variables') %Saves variables for checkpointing for start/restart capability
        end
        %Evaluating for U (solution) values defined by Neumann Boundary
        %Conditions that are evaluated by Gauss-Seidel Method
        for j = 2:MM
            W(1,j) = U(1,j); %W saves value of U for error calculation
            U(1,j) = (- 2 * (DY^2) * U(2,j) - (DX^2) * U(1,j-1) - (DX^2) * U(1,j+1)) / A;  %cos((pi() / 2) * (0 + 1)) = 0 so Fi,j = 0, Neumann condition for X = -pi
            U(1,j) = (G * U(1,j)) + ((1-G) * W(1,j)); %Applying SOR iteration
            Error(1,j) = abs((U(1,j) - W(1,j)) / U(1,j)); %Computes relative error for this calculation inside this iteration
            
            W(N,j) = U(N,j); %W saves value of U for error calculation
            U(N,j) = (- 2 * (DY^2) * U(NN,j) - (DX^2) * U(N,j-1) - (DX^2) * U(N,j+1)) / A; %cos(3 * pi() / 2) = 0 so Fi,j = 0, Neumann condition for X = pi
            U(N,j) = (G * U(N,j)) + ((1-G) * W(N,j)); %Applying SOR iteration
            Error(N,j) = abs((U(N,j) - W(N,j)) / U(N,j)); %Computes relative error for this calculation inside this iteration
        end
        %Evaluating for general expression (internal nodes):
        for j = 2:MM
            for i = 2:NN
                W(i,j) = U(i,j); %W saves value of U for error calculation
                U(i,j) = (B * (cos((pi() / 2) * ((((i-1) * DX) / pi()) + 1)) * sin(((j - 1) * DY) / 2)) - (DY^2) * U(i-1,j) - (DY^2) * U(i+1,j) - (DX^2) * U(i,j-1) - (DX^2) * U(i,j+1)) / A;
                U(i,j) = (G * U(i,j)) + ((1-G) * W(i,j)); %Applying SOR iteration
                Error(i,j) = abs((U(i,j) - W(i,j)) / U(i,j)); %Computes relative error for this calculation inside this iteration
            end
        end
        Ea = max(max(Error));
        Z = Z + 1; %Counts the number of loop iterations
        T = toc; %Determines how long the Gauss-Seidel iteration took
        Tcounter = Tcounter + T; %Counts how much time has elapsed since the last variable checkpoint save
    end
else
    disp('Select a different number of nodes for X or Y domain or change the value of C, the given constant for capital lambda.')
end
save('Variables.mat')
%%
%Plotting visualizations for ease of interpretation of results:
load('Variables.mat') %Provides the option of loading the variables directly onto the plot section, if a failure occurs while plotting

figure
surf(U) %Produces surface plot of solution matrix for Helmholtz equation:

%Plotting contour lines of U, the solution matrix for 2-D interpretation of
%results obtained:
X = zeros(N,1);
for i = 1:N
    X(i,1) = -pi() + (i-1) * DX; %Defines values along X-axis for plot, from -pi to pi along X domain
end
Y = zeros(M,1);
for j = 1:M
    Y(j,1) = -pi() + (j-1) * DY; %Defines values along Y-axis for plot, from -pi to pi along Y domain
end
figure
[Matrix, Object] = contourf(Y, X, U); %Plots the contour of the solution matrix
xlabel('Y axis'), ylabel('X axis')
clabel(Matrix, Object) %Labels the peak values for all of the contour lines