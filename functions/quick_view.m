function volume = quick_view(input_file)

volume = [];
if endsWith(input_file, 'DICOMDIR','IgnoreCase',true)
    
else
%     try volume = imread(input_file);
%     catch
%         try volume_temp = load_nii(input_file);
% %             volume = volume_temp.img;
%             try rgb2gray(volume_temp.img)
%             catch
%             end
%             volume(:,:)=rot90(fliplr(volume_temp.img(:,:)),-1);
%         catch
            try volume = dicomread(input_file);
            catch
%                 try
%                     hdr = nhdr_nrrd_read(fullfile(input_file), true);
%                     volume = hdr.data;
%                 catch
%                 end
            end
%         end
%     end
end