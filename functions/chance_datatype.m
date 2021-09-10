function [object, datatype] = chance_datatype(object,tipo)

switch tipo
      case 'uint8'
         object = uint8(object);
         datatype = 2;
      case 'int16'
         object = int16(object);
         datatype = 4;
      case 'int32'
         object = int32(object);
         datatype = 8;
      case 'single'
         object = single(object);
%          if isreal(nii.img)
            datatype = 16;
%          else
%             datatype = 32;
%          end
      case 'double'
         object = double(object);
%          if isreal(nii.img)
            datatype = 64;
%          else
%             datatype = 1792;
%          end
      case 'int8'
         object = int8(object);
         datatype = 256;
      case 'uint16'
         object = uint16(object);
         datatype = 512;
      case 'uint32'
         object = uint32(object);
         datatype = 768;
      otherwise
         error('Datatype is not supported by make_nii.');
end