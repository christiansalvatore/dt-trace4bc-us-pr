function feature = racat_simplefeatextraction_habitat(in__file, in__mask,...
    img__type, patient__root, feat_name, feat_abbr)
    
    % Running RaCat
    %  Note: specifing the absolute paths is necessary.
    %  Change it accordingly!
    %
    %  path to .exe compiled RaCat file
    %  --ini = path to configuration file
    %  --img = path to image file (nifti format)
    %  --voi = path to mask file (nifti format)
    %  --out = path to output csv file

    p = mfilename('fullpath');
    endout = regexp(p, filesep, 'split');

    for i = 1:size(endout,2)-2
        if i == 1
            path_exe = endout{1,1};
        else
            path_exe = strcat(path_exe, '/' ,endout{1,i});
        end  
    end

    output_path = fullfile(patient__root, 'results_temp');
    mkdir__ifnotexist(output_path);
    output_name = fullfile(output_path, [img__type '_RacatOutput']);
    
    if strcmp(img__type, 'PET')
        in_config = strcat(path_exe,'\RaCat\config__IBSI-C__PET.ini');
        in_paz = strcat(path_exe,'\RaCat\patientInfo.ini');
        command_racat = strcat('"',path_exe,'"', '\RaCat\RaCaT_v1.4.exe --ini ', ...
            {' '}, '"',in_config,'"', ' --img ', {' '},'"', in__file,'"', ' --voi ', ...
            {' '}, '"',in__mask,'"', ' --out ', {' '},'"', output_name,'"', ' --pat ', ...
            {' '}, '"',in_paz,'"');
    elseif strcmp(img__type, 'CT') || strcmp(img__type, 'TC')
        in_config = strcat(path_exe,'\RaCat\config__IBSI-C__CT.ini');
        command_racat = strcat('"',path_exe,'"', '\RaCat\RaCaT_v1.4.exe --ini ', ...
            {' '},'"', in_config,'"', ' --img ', {' '}, '"', in__file, '"', ' --voi ', ...
            {' '}, '"', in__mask, '"', ' --out ', {' '}, '"', output_name, '"');
    elseif strcmp(img__type, 'MAMMOGRAPHY') || strcmp(img__type, 'RX')
        in_config = strcat(path_exe,'\RaCat\config__IBSI-B__2D__CT.ini');
        command_racat = strcat('"',path_exe,'"', '\RaCat\RaCaT_v1.4.exe --ini ', ...
            {' '},'"', in_config,'"', ' --img ', {' '},'"', in__file,'"', ' --voi ', ...
            {' '},'"', in__mask,'"', ' --out ', {' '},'"', output_name,'"');
    elseif strcmp(img__type, 'CYBERKNIFE')
        in_config = strcat(path_exe, '\RaCat\config__IBSI-C__MRI.ini');
        command_racat = strcat('"',path_exe,'"', '\RaCat\RaCaT_v1.4.exe --ini ', ...
            {' '},'"', in_config,'"', ' --img ', {' '},'"', in__file,'"', ' --voi ', ...
            {' '},'"', in__mask,'"', ' --out ', {' '},'"', output_name,'"');
    elseif strcmp(img__type, 'ADC')
        in_config = strcat(path_exe, '\RaCat\config__IBSI-C__ADC.ini');
        command_racat = strcat('"',path_exe,'"', '\RaCat\RaCaT_v1.4.exe --ini ', ...
            {' '},'"', in_config,'"', ' --img ', {' '},'"', in__file,'"', ' --voi ', ...
            {' '},'"', in__mask,'"', ' --out ', {' '},'"', output_name,'"');
    elseif strcmp(img__type, 'T2')
        in_config = strcat(path_exe, '\RaCat\config__IBSI-C__T2.ini');
        command_racat = strcat('"',path_exe,'"', '\RaCat\RaCaT_v1.4.exe --ini ', ...
            {' '},'"', in_config,'"', ' --img ', {' '},'"', in__file,'"', ' --voi ', ...
            {' '},'"', in__mask,'"', ' --out ', {' '},'"', output_name,'"');
    elseif strcmp(img__type, 'US') || strcmp(img__type, 'RETINOGRAPHY')
        in_config = strcat(path_exe, '\RaCat\config__IBSI-B__2D__MRI.ini');
        command_racat = strcat('"',path_exe,'"', '\RaCat\RaCaT_v1.4.exe --ini ', ...
            {' '},'"', in_config,'"', ' --img ', {' '},'"', in__file,'"', ' --voi ', ...
            {' '},'"', in__mask,'"', ' --out ', {' '},'"', output_name,'"');
    end

    command_racat = command_racat{1};
    system(command_racat)

    % Loading .csv files and merging features in a .mat cell
    racat_csv = readtable(strcat(output_name,'.csv'));

    % note that Splitting name and feature values is necessary because table2array does not manage cell and
    % double formats in the same input)

    tot_feat = size(racat_csv,1);
    racat_feat_name = table2array(racat_csv(1:tot_feat,1:2));
    racat_feat_values = table2array(racat_csv(1:tot_feat,3));
    check = 0;
    for i = 1:tot_feat
        if strcmpi (racat_feat_name{i,1}, feat_abbr)
            if strcmpi (racat_feat_name{i,2}, feat_name)
                feature=racat_feat_values(i,1);
                check=1;
            end
        end
    end
    if check == 0
        feature = [];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     racat_feat_str = racat_feat_str(1:9, :);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Remove output folder with subfolders and files
    rmdir(output_path,'s');
end
