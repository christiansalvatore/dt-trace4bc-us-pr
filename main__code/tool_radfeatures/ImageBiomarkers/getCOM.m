function com = getCOM(Xgl_int,Xgl_morph,XYZ_int,XYZ_morph)
% -------------------------------------------------------------------------
% AUTHOR(S): 
% - Martin Vallieres <mart.vallieres@gmail.com>
% -------------------------------------------------------------------------
% HISTORY:
% - Creation: April 2017
% - Revision I: August 2017
% -------------------------------------------------------------------------
% DISCLAIMER:
% "I'm not a programmer, I'm just a scientist doing stuff!"
% -------------------------------------------------------------------------
% STATEMENT:
% This file is part of <https://github.com/mvallieres/radiomics-develop/>, 
% a private repository dedicated to the development of programming code for
% new radiomics applications.
% --> Copyright (C) 2017  Martin Vallieres
%     All rights reserved.
%
% This file is written on the basis of a scientific collaboration for the 
% "radiomics-develop" team.
%
% By using this file, all members of the team acknowledge that it is to be 
% kept private until public release. Other scientists willing to join the 
% "radiomics-develop" team is however highly encouraged. Please contact 
% Martin Vallieres for this matter.
% -------------------------------------------------------------------------

% CALCULATE CENTER OF MASS SHIFT (in mm, since "res" is in mm)
% - Xgl: Vector of intensity values in the volume to analyze.
% - XYZ: [nPoints X 3] matrix of three column vectors, defining the [X,Y,Z]
%        positions of the points in the ROI (1's) of the mask volume.
%        --> In mm.
%
% IMPORTANT: Row positions of "Xgl" and "XYZ" must correspond for each point.


% Getting the geometric centre of mass
Nv = numel(Xgl_morph);
com_geom = sum(XYZ_morph)/Nv; % [1 X 3] vector

% Getting the density centre of mass
XYZ_int(:,1) = Xgl_int.*XYZ_int(:,1);
XYZ_int(:,2) = Xgl_int.*XYZ_int(:,2);
XYZ_int(:,3) = Xgl_int.*XYZ_int(:,3);
com_gl = sum(XYZ_int)/sum(Xgl_int); % [1 X 3] vector

% Calculating the shift
com = norm(com_geom - com_gl);

end