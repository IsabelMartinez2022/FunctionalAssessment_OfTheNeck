%Task 1
%Saves the Euler angles measured with the headset to a new file
%Saves the location of the first apple that appears and every apple that is
%stored

if not(isfolder("GroupA_extracted"))
mkdir("GroupA_extracted")
end

if not(isfolder("GroupB_extracted"))
mkdir("GroupB_extracted")
end

readCSV('GroupA');
readCSV('GroupB');

function readCSV(patientsgroup)

rootfolder = pwd;
patients= dir(fullfile(rootfolder,patientsgroup,'*.csv'));

for i = 1:length(patients)
    path = fullfile(rootfolder,patientsgroup);
    opts = detectImportOptions(fullfile(path, patients(i).name));
    opts = setvartype(opts,'string');
    patient_data = readtable(fullfile(path, patients(i).name),opts);
    
    %We search for the first apple that appears in each patient
    for j= 1:size(patient_data)
        if contains(patient_data(j,:).Var3, "spawn,Apple 0")
            patient_data_initiated= patient_data(j:height(patient_data),:);
        end
    end

    % We search for the headset (H) data and location of stored apples
    search = ["H","stored"];
    headset_data = patient_data_initiated(contains(patient_data_initiated.Var3,search), :);
    % We extract the Euler angles (x, y, z) from the headset data and the positition of the
    % stored apples
    euler_angles = headset_data(:, [1 2 3 11:13]);
    % We save the extracted data to a new CSV file
    cd (rootfolder+"\"+patientsgroup+"_extracted\");
    filename= strcat(erase(patients(i).name,".csv"),'_extracted.csv');
    writetable(euler_angles, filename);
end
cd (rootfolder);

end
