function out = morph2Dfeatures(vol__path, mask__path,pix_dim)

% volnii = load_nii(vol__path);
vol = vol__path;

% masknii = load_nii(mask__path);
mask = mask__path;
if length(pix_dim)==1
    pix_dim(1,2)=pix_dim;
end
% pix_dim=volnii.hdr.dime.pixdim(2:3);
vect_val=[0;0];
calcolo_lesione=nonzeros(mask);
dim_l=size(calcolo_lesione);
Area = dim_l(1,1)*pix_dim(1,1)*pix_dim(1,1);%%%%%%%%
vect_val(1,1)=Area;
contor_pix = bwboundaries(mask);
contor_pix=contor_pix{1};
Contorno=0;
for i=1:length(contor_pix)-1
Contorno=Contorno+(sqrt((contor_pix(i,1)-contor_pix(i+1,1))^2 ...
	+(contor_pix(i,2)-contor_pix(i+1,2))^2));
end
Contorno=Contorno*pix_dim(1,1);%%%%%%%%
vect_val(2,1)=Contorno;
% for i = 1:length(contor_pix)
%     roi=mask(contor_pix(i,1)-1:contor_pix(i,1)+1,...
%         contor_pix(i,2)-1:contor_pix(i,2)+1);
%     roi(1,1)=10;
%     roi(1,3)=10;
%     roi(3,1)=10;
%     roi(3,3)=10;
%     zeri=find(roi==0);
%     Contorno=Contorno+length(zeri)*pix_dim(1,1)/10;
% end

vect_val=[];
cc = bwconncomp(mask,8);
max_area=0;
for i = 1:length(cc.PixelIdxList)
    if length(cc.PixelIdxList{i})>max_area
        max_area = length(cc.PixelIdxList{i});
        index_max_area = i;
    end
end
for i = 1:length(cc.PixelIdxList)
    if i~=index_max_area
        mask(cc.PixelIdxList{i})=0;
    end
end
% calcolo_lesione=nonzeros(mask);
% calcolo_lesione = max_area;
% dim_l=size(calcolo_lesione);
dim_l = max_area;
Area = dim_l(1,1)*pix_dim(1,1)*pix_dim(1,1);%%%%%%%%
vect_val(1,1)=Area;

contor_pix = bwboundaries(mask);
max_length=0;
for i = 1:length(contor_pix)
    if length(contor_pix{i})>max_length
        max_length = length(contor_pix{i});
        index_max_length = i;
    end
end
contor_pix=contor_pix{index_max_length};
Contorno=0;
for i=1:length(contor_pix)-1
Contorno=Contorno+(sqrt(((contor_pix(i,1)-contor_pix(i+1,1))*pix_dim(1,1))^2 ...
	+((contor_pix(i,2)-contor_pix(i+1,2))*pix_dim(1,2))^2));
end
% Contorno=Contorno*pix_dim(1,1);%%%%%%%%
vect_val(2,1)=Contorno;


CA_rapporto=Contorno/Area;%%%%%%%
vect_val(3,1)=CA_rapporto;
Compactness=4*pi*Area/(Contorno^2);%%%%%%%
vect_val(4,1)=Compactness;
Circular=(2*sqrt(pi*Area))/Contorno;%%%%%%%
vect_val(5,1)=Circular;
Acircularity=(Contorno/sqrt(4*pi*Area))-1;%%%%%%%
vect_val(6,1)=Acircularity;


[coord(:,1),coord(:,2)]=find(mask);
struct_center_coord=sum(coord)./length(coord);

% temp_vol=vol.*mask;

for i=1:length(coord)
    coord(i,3)=vol(coord(i,1),coord(i,2));
end
coord(:,4:5)=coord(:,1:2).*coord(:,3);
denom=sum(coord(:,3));
numer=sum(coord(:,4:5));
intens_center_coord=numer./denom;
diff_coord=(struct_center_coord(1,:)-intens_center_coord(1,:));
Centroid_shift=sqrt(sum(diff_coord.^2));%%%%%%%%%%%
vect_val(7,1)=Centroid_shift;

Max_diam=0;
for i=1:length(contor_pix)
    for j=1:length(contor_pix)
        if i~=j
            dist=sqrt((contor_pix(i,1)-contor_pix(j,1))^2 ...
            +(contor_pix(i,2)-contor_pix(j,2))^2);
            if dist>Max_diam
                Max_diam=dist;
            end
        end
    end
end
Max_diam=Max_diam*pix_dim(1,1);%%%%%%
vect_val(8,1)=Max_diam;
box=zeros(size(mask));
box(min(coord(:,1)):max(coord(:,1)),min(coord(:,2)):max(coord(:,2)))=1;
calcolo_box=nonzeros(box);
dim_2=size(calcolo_box);
area_box = dim_2(1,1)*pix_dim(1,1)/10*pix_dim(1,2)/10;%%%%%%%%%% moltiplicare per 100?
Area_density=Area/area_box;%%%%%%
vect_val(9,1)=Area_density;
contorno_box=((max(coord(:,1))-min(coord(:,1))+1)*2+ ...
    (max(coord(:,2))-min(coord(:,2))+1)*2)*pix_dim(1,1);
Contorno_density=Contorno/contorno_box;%%%%%%
vect_val(10,1)=Contorno_density;

out.vect_val = vect_val;

%extra moph
CC = bwconncomp(mask);
    if CC.NumObjects>1
        max_area=0;
        for j = 1:length(CC.PixelIdxList)
            if length(CC.PixelIdxList{j})>=max_area
                max_area = length(CC.PixelIdxList{j});
                index_max_area = j;
            else
                mask(CC.PixelIdxList{j})=0;
            end
        end
        CC = bwconncomp(mask);
        for j = 1:length(CC.PixelIdxList)
            if length(CC.PixelIdxList{j})>=max_area
                max_area = length(CC.PixelIdxList{j});
                index_max_area = j;
            else
                mask(CC.PixelIdxList{j})=0;
            end
        end
        CC = bwconncomp(mask);
    end
stats = regionprops(CC,'Circularity',...
    'MajorAxisLength','MinorAxisLength',...
    'Orientation', 'Solidity','Eccentricity','Extent');
proiez_x_major_mm = (stats.MajorAxisLength*cos(deg2rad(abs(stats.Orientation))))*pix_dim(1,1);
proiez_y_major_mm = (stats.MajorAxisLength*sin(deg2rad(abs(stats.Orientation))))*pix_dim(1,2);
stats.MajorAxisLength_mm = hypot(proiez_x_major_mm,proiez_y_major_mm);


proiez_x_minor_mm = (stats.MinorAxisLength*cos(deg2rad(abs(90-stats.Orientation))))*pix_dim(1,1);
proiez_y_minor_mm = (stats.MinorAxisLength*sin(deg2rad(abs(90-stats.Orientation))))*pix_dim(1,2);
stats.MinorAxisLength_mm = hypot(proiez_x_minor_mm,proiez_y_minor_mm);


out.other_morph(1,1) = Max_diam;
out.other_morph(1,2) = Area;
out.other_morph(1,3) = stats.Orientation;
out.other_morph(1,4) = stats.Solidity;
out.other_morph(1,5) = stats.Eccentricity;
if stats.Orientation > -45 && stats.Orientation < 45
    out.other_morph(1,6) = 0; % paralel
else
    out.other_morph(1,6) = 1; % normal
end
if stats.Solidity < 0.88
    out.other_morph(1,7) = 2; % irregular
else
    if stats.Eccentricity < 0.4 
        out.other_morph(1,7) = 0; % circular
    else
        out.other_morph(1,7) = 1; % oval
    end
end

% try racat_table = readtable(strcat(path_exe,'\main_code\functions\RaCat\dataframe_IBSI__RaCaT__nomenclature_mam.csv'));
% catch
%     racat_table = readtable(strcat(path_exe,'\functions\RaCat\dataframe_IBSI__RaCaT__nomenclature_mam.csv'));
% end
% % tot_table=size(racat_table,1);
% 
% % racat_feat_name = table2array(racat_table(1:tot_table,9));
% % racat_feat_name2 = table2array(racat_table(1:tot_table,1:2));
% % ract_feat{:,1}=racat_feat_name2(:,1);
% % ract_feat{:,2}=racat_feat_name2(:,2);
% % ract_feat{:,3}=vect_val{:,1};
% racat_table1=racat_table;
% 
% tot_table1=size(racat_table1,1);
% racat_feat_str = table2array(racat_table1(1:tot_table1,:));
% for i=1:tot_table1
%     racat_units{i,1} = racat_feat_str{i,11};
%     racat_units{i,2} = racat_feat_str{i,12};
% end
% 
% racat_feat_str(:,6:9)=[];
% 
% for i=1:tot_table1
%     if strcmp(racat_feat_str(i,6),'FB')
%         racat_feat_str{i,7}='FBN:32';
%     elseif strcmp(racat_feat_str(i,6),'FB1')
%         racat_feat_str{i,7}='--';
%     else
%         racat_feat_str{i,7}='--';
%     end
%     racat_feat_str{i,6}='US';
%     racat_feat_str{i,8}='LIN:--';
%     racat_feat_str{i,9}='S:--';
%     racat_feat_str{i,10}='RS:--';
%     val=vect_val(i,1);
%     racat_feat_str{i,11}=val;
%     racat_feat_str{i,12}=racat_units{i,2};
end

% nome_excel = fullfile(output_path, [nome '_' im_type '_features.xlsx']);
% titles={'Feature Family', 'Feature name', 'Family abbr.', 'Aggregation',...
%     'Dimensions','Acquisition','Discretization','Interpolation',...
%     'Re-sampling', 'Re-segmentation', 'Feature Value', 'unit'};
% xlswrite(nome_excel,titles,'Foglio1','A1')
% xlswrite(nome_excel,racat_feat_str,'Foglio1','A2')

