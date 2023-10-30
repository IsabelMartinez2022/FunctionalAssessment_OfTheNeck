%Task1
%Saves the Euler angles measured with the headset to a new file

rootfolder = pwd;
patientsA= dir(fullfile(rootfolder,'GroupA','*.csv'));

if not(isfolder("GroupA_extracted"))
mkdir("GroupA_extracted")
end

for i = 1:length(patientsA)
    pathA = fullfile(rootfolder,'GroupA');
    opts = detectImportOptions(fullfile(pathA, patientsA(i).name));
    opts = setvartype(opts,'string');
    patient_data = readtable(fullfile(pathA, patientsA(i).name),opts);
    % We search for the headset (H) data
    headset_data = patient_data(strcmp(patient_data.Var3, 'H'), :);
        % We extract the Euler angles (x, y, z) from the headset 
        euler_angles = headset_data(:, 11:13);
        % We save the extracted data to a new CSV file
        cd (rootfolder+"\GroupA_extracted\");
        filename= strcat(erase(patientsA(i).name,".csv"),'_extracted.csv');
        writetable(euler_angles, filename);
end

cd (rootfolder);
patientsB= dir(fullfile(rootfolder,'GroupB','*.csv'));

if not(isfolder("GroupB_extracted"))
mkdir("GroupB_extracted")
end

for j = 1:length(patientsB)
    pathB = fullfile(rootfolder,'GroupB');
    opts = detectImportOptions(fullfile(pathB, patientsB(j).name));
    opts = setvartype(opts,'string');
    patient_data = readtable(fullfile(pathB, patientsB(j).name),opts);
    % We search for the headset (H) data
    headset_data = patient_data(strcmp(patient_data.Var3, 'H'), :);
        % We extract the Euler angles (x, y, z) from the headset 
        euler_angles = headset_data(:, 11:13);
        % We save the extracted data to a new CSV file
        cd (rootfolder+"\GroupB_extracted\");
        filename= strcat(erase(patientsA(i).name,".csv"),'_extracted.csv');
        writetable(euler_angles,strcat(erase(patientsB(j).name,".csv"),'_extracted.csv'));
end


