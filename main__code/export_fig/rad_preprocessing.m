function out = rad_preprocessing(in, kernel1, kernel2, med_ker)
    % Pre-processing of the rad image
    
    % [from http://stackoverflow.com/questions/5450228/remove-paper-texture-pattern-from-a-photograph]
    % 1.  Detect the paper texture pattern:
    % 1.1 Apply Gaussian blur to the image (use a large kernel to make sure
    % that all the paper texture information is destroyed)
    
    imm = imgaussfilt(in, kernel1);%50
%     figure
%     imshow(imm,[])
    % 1.2 Calculate the image difference between the blurred and original images
    diff = imm - in;
%     figure
%     imshow(diff,[])
    % 1.3 Apply Gaussian blur to the difference image (use a small 3x3 kernel)
    imm = imgaussfilt(diff, kernel2);%3
%     figure
%     imshow(imm,[])
    imm = imm - min(min(imm));
%     figure
%     imshow(imm,[])
    imm = imm./max(max(imm));
%     figure
%     imshow(imm,[])
    % 2.  Use median filtering to replace only the parts of the image that
    % correspond to the paper pattern (weighted replacement)
    fimg = medfilt2(in,[med_ker med_ker]);%10
    k = 0;
    out = (1-imm-k).*in + (imm+k).*fimg;
    figure
    imshow(out,[])
end