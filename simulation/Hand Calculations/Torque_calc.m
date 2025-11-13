% Ameen Aydan 
% Torque Calculation Script

% Define angle in degrees
% phi = azimuth ccw from +x
% theta = angle from +z
% CCW = pos CW = neg RHR rule!

clear all;

theta = 45;  
phi_1 = 0; 
phi_2 = 120;
phi_3 = 240;

r_s = 0.3; % sphere radius in meters
r_ow = 0.015; % omniwheel radius in meters

% T_m1 = ;
% T_m2 = ;
% T_m3 = ;

syms T_m1 T_m2 T_m3

[n_1, e_1] = sphere_basis(theta, phi_1);
[n_2, e_2] = sphere_basis(theta, phi_2);
[n_3, e_3] = sphere_basis(theta, phi_3);

% Direction of nxF matters! It makes the results positive or negative
% Motor Torque Vector
T_m = [T_m1; T_m2; T_m3];

% Motor --> Sphere Torque Translation Matrix

% T_s_m1 = ((-r_s/r_ow)*(T_m1))*cross(n_1, e_1);
% T_s_m2 = ((-r_s/r_ow)*(T_m2))*cross(n_2, e_2);
% T_s_m3 = ((-r_s/r_ow)*(T_m3))*cross(n_3, e_3);

T_s_m1 = ((-r_s/r_ow))*cross(n_1, e_1);
T_s_m2 = ((-r_s/r_ow))*cross(n_2, e_2);
T_s_m3 = ((-r_s/r_ow))*cross(n_3, e_3);

% Ball torque for a given motor torque
T_s = [T_s_m1 T_s_m2 T_s_m3]*T_m;
   
 

