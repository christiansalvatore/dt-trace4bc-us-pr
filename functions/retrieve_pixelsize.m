function dx = retrieve_pixelsize(app)

if endsWith(app.file, '.nii','IgnoreCase',true)
        vol = load_nii(fullfile(app.path,app.file));
        try 
            if size(vol.img,3)>1
                dx = 1;
                return
            end
        catch
        end
        try
            dx = vol.hdr.dime.pixdim(2:4);
        catch
            %error pix size
            dx = [0.5,0.5,0.5];
        end
elseif endsWith(app.file, '.nrrd','IgnoreCase',true)
    hdr = nhdr_nrrd_read(fullfile(app.path,app.file), true);
    try 
        if hdr.sizes(3)>1
            dx = 1;
            return
        end
    catch
    end
    try
        dx = [hdr.spacedirections_matrix(1,1)...
            hdr.spacedirections_matrix(2,2)...
            hdr.spacedirections_matrix(3,3)];
    catch 
        dx = [0.5,0.5,0.5];
    end
else
    try output.info = dicominfo(fullfile(app.path, app.file));
        try dx(1,1)=output.info.PixelSpacing(1);
            dx(1,2)=output.info.PixelSpacing(2);
            try dx(1,3)=output.info.SliceThickness;
            catch
                dx(1,3)=1;
            end
        catch
            try dx(1,1) = 10*output.info.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX;
                dx(1,2) = 10*output.info.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX;
                try dx(1,3)=output.info.SliceThickness;
                catch
                    dx(1,3) = 1;%hdr.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX;
                end
            catch
                dx = [0.5,0.5,0.5];
                %voxel size not fount
            end
        end
    catch
        dx = 'a';
    end
end