%Tasks 4, 5 and 6
%Average spectral power calculation
%Statistical tests

average_groupA= spectralPower('GroupA');
average_groupB= spectralPower('GroupB');
[h_groupA, h_groupB]= analysis(average_groupA, average_groupB);

function avgpower= spectralPower (groupname)

%Contains the avg spectral power for all 4 measurements (x,y,z,total), 
%in all 11 frequency bands, for all 30 group patients
avgpower=zeros(30,11,4);
patient_index=1;

rootfolder = pwd;
addpath(rootfolder);
groupfolder= rootfolder+"\"+groupname+"_extracted\";
cd (groupfolder);

for i=1:200

    window_length =128;
    overlap = 18;
    f=[1, 3, 7, 9, 11, 13, 15, 17, 19, 21, 23];

    if isfile("Pte_"+i+"​_extracted.csv")

        read_data= readtable("Pte_"+i+"​_extracted.csv");
        read_data.Var3 = string(read_data.Var3);
        read_data.Var1 = num2str(read_data.Var1);
        read_data_array = table2array(read_data);
        rowsEuler= ~contains(read_data_array(:, 3), "stored");
        patient_xyz= str2double(strrep(read_data_array(rowsEuler,:),',','.')); 

        %We discard the first 30 seconds to ignore quiet at the beginning
        fs= 50; 
        discard_samples = 30 * fs;
        patient_x=patient_xyz(:,4)-patient_xyz(1,4);
        patient_x = patient_x(discard_samples+1:end);
        patient_y=patient_xyz(:,5)-patient_xyz(1,5);
        patient_y = patient_y(discard_samples+1:end);
        patient_z=patient_xyz(:,6)-patient_xyz(1,6);
        patient_z = patient_z(discard_samples+1:end);
        
        %Power spectral densities are calculated using the spectrogram function for each band
        [~,~,~,psx]= spectrogram(patient_x,window_length,overlap, f, fs, "power",'yaxis');
        [~,~,~,psy]= spectrogram(patient_y,window_length,overlap, f, fs, "power",'yaxis');
        [~,~,~,psz]= spectrogram(patient_z,window_length,overlap, f, fs, "power",'yaxis');
        [~,~,~,psxyz]= spectrogram((abs(patient_x)+abs(patient_y)+abs(patient_z)),window_length,overlap, f, fs,'yaxis');
        
        %Avarage
        avgpower(patient_index,:,1)= mean(psx,2);
        avgpower(patient_index,:,2)= mean(psy,2);
        avgpower(patient_index,:,3)= mean(psz,2);
        avgpower(patient_index,:,4)= mean(psxyz,2);

        patient_index=patient_index+1;
    end 
end

cd (rootfolder)
%name = ['avgpower_',groupname,'.mat'];
%save(name,'avgpower');

end 


function [h_groupA,h_groupB]= analysis (avg_groupA, avg_groupB)

%Check normality
h_groupA= zeros(4,11);
h_groupB= zeros(1,11);

%Loop through each measurement
for k = 1:4 
    %Loop through each frequency band for all patients
    for j = 1:11 
        h_groupA(k, j) = adtest(avg_groupA(:, j, k));
        h_groupB(k, j) = adtest(avg_groupB(:, j, k));

        %{
        %To check visually the rejected distributions
        figure;
        if h_groupA(k,j)==1
        subplot(2, 1, 1);
        histogram(avg_groupA(:,j, k), 'Normalization', 'count');
        end

        subplot(2, 1, 2);
        if h_groupB(k,j)==1
        histogram(avg_groupB(:,j, k), 'Normalization', 'count');
        end
        %}
    end
end
end
