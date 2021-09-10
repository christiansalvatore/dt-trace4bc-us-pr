function [volume, mask] = crop_to_mask(volObjInit, roiObjInit, pix, is3D)
% volObjInit.data
% roiObjInit.data


if is3D
    [x,y,z] = ind2sub(size(roiObjInit.data),find(roiObjInit.data>0));
else
    [x,y] = find(roiObjInit.data);
    z = [1 1];
end
xr = range(x);
yr = range(y);
zr = range(z);

xb = round(max(xr*0.05,5));
xl = max(min(x)-xb,1);
xh = min(max(x)+xb,size(roiObjInit.data,1));

yb = round(max(yr*0.05,5));
yl = max(min(y)-yb,1);
yh = min(max(y)+yb,size(roiObjInit.data,2));


if is3D
    if pix(3)>pix(1)
        zb = round(max(zr*0.05,2));
    else
        zb = round(max(zr*0.05,5));
    end
    zl = max(min(z)-zb,1);
    zh = min(max(z)+zb,size(roiObjInit.data,3));
else
    zl = 1;
    zh = 1;
end

try volume = volObjInit.data(xl:xh,yl:yh,zl:zh);
    mask = roiObjInit.data(xl:xh,yl:yh,zl:zh);
catch
    volume = volObjInit.data(xl:xh,yl:yh);
    mask = roiObjInit.data(xl:xh,yl:yh);
end






