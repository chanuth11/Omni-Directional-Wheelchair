function [n_hat, e_theta] = sphere_basis(theta_deg, phi_deg)
% SPHERE_BASIS  Returns the normal (n_hat) and tangential (e_theta)
%               unit vectors at a point on a sphere defined by angles.
%
% Inputs:
%   phi_deg   - azimuth angle [deg], measured from +x toward +y
%   theta_deg - [deg], measured from +z downward
%
% Outputs:
%   n_hat     - 3x1 unit normal vector (outward from sphere center)
%   e_theta   - 3x1 unit tangent vector in direction of increasing theta
%               (points "downhill" toward -z)

    % Convert to radians
    phi = deg2rad(phi_deg);
    theta = deg2rad(theta_deg);

    % Unit normal (outward)
    n_hat = [sin(theta)*cos(phi);
             sin(theta)*sin(phi);
             cos(theta)];


    % Tangential unit vector (increasing theta)
    e_theta = [cos(theta)*cos(phi);
               cos(theta)*sin(phi);
               -sin(theta)];
end