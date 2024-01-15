%Tasks 4, 5 and 6
%Average spectral power and duration 
%Statistical tests
%Average duration of the spectrograms with its standard deviation 


average_groupA= spectralPower('GroupA');
average_groupB= spectralPower('GroupB');
[hypothesis_values, p_values,means,std_deviations]= analysis(average_groupA, average_groupB);
[avg_duration_groupA, stdev_duration_groupA]= durationSpectrogram('GroupA');
[avg_duration_groupB, stdev_duration_groupB]= durationSpectrogram('GroupB');


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
        rowsEuler= ~contains(read_data_array(:, 3),"stored");
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
        [~,~,~,psx]= spectrogram(patient_x,window_length,overlap,f,fs,"power",'yaxis');
        [~,~,~,psy]= spectrogram(patient_y,window_length,overlap,f,fs,"power",'yaxis');
        [~,~,~,psz]= spectrogram(patient_z,window_length,overlap,f,fs,"power",'yaxis');
        [~,~,~,psxyz]= spectrogram((abs(patient_x)+abs(patient_y)+abs(patient_z)),window_length,overlap,f,fs,'yaxis');
        
        %Average
        avgpower(patient_index,:,1)= mean(psx,2);
        avgpower(patient_index,:,2)= mean(psy,2);
        avgpower(patient_index,:,3)= mean(psz,2);
        avgpower(patient_index,:,4)= mean(psxyz,2);

        patient_index=patient_index+1;
    end 
end

cd (rootfolder)
end 


function [hypothesis_values,p_values,means,std_deviations]= analysis (avg_groupA, avg_groupB)

h_groupA= zeros(4,11);
h_groupB= zeros(4,11);
hypothesis_values= zeros(4,11);
p_values= zeros(4,11);
means=zeros(2,11,4);
std_deviations=zeros(2,11,4);

%Loop through each measurement
for k = 1:4 
    %Loop through each frequency band for all patients
    for j = 1:11 

        %To check normality
        h_groupA(k,j) = adtest(avg_groupA(:,j,k));
        h_groupB(k,j) = adtest(avg_groupB(:,j,k));

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

        %We perform t-test or Whitney-U-test based on normality assumptions
        if h_groupA(k,j)|| h_groupB(k,j)
            [p_values(k,j),hypothesis_values(k,j)]= ranksum(avg_groupA(:,j,k), avg_groupB(:,j,k));
        else 
            [hypothesis_values(k,j),p_values(k,j)]= ttest2(avg_groupA(:,j,k), avg_groupB(:,j,k));
        end 
        
        %We calculate mean and std deviation for those bands with
        %statistical differences between groups
        if hypothesis_values(k,j)
            means(1,j,k)= mean(avg_groupA(:,j,k));
            means(2,j,k)= mean(avg_groupB(:,j,k));
            std_deviations(1,j,k)= std(avg_groupA(:,j,k));
            std_deviations(2,j,k)= std(avg_groupB(:,j,k));
        end 
       
    end
end
end


%We calculate the average duration of the spectrograms and its std deviation 
%for each group
function [avg_duration, stdev_duration]= durationSpectrogram(groupname)

rootfolder = pwd;
addpath(rootfolder);
groupfolder= rootfolder+"\"+groupname+"_extracted\";
cd (groupfolder);

avg_duration= zeros(2,1);
stdev_duration= zeros (2,1);
duration_patients= zeros(1,30);
index=1;

for i=1:200

    window_length =128;
    overlap = 18;
    f=[1, 3, 7, 9, 11, 13, 15, 17, 19, 21, 23];

    if isfile("Pte_"+i+"​_extracted.csv")

        read_data= readtable("Pte_"+i+"​_extracted.csv");
        read_data.Var3 = string(read_data.Var3);
        read_data.Var1 = num2str(read_data.Var1);
        read_data_array = table2array(read_data);
        patient_xyz= str2double(strrep(read_data_array,',','.')); 
       
        duration_patients(index)= patient_xyz(size(patient_xyz,1),2);
        index= index+1;
    end 
end

avg_duration= mean(duration_patients);
stdev_duration= std(duration_patients);

cd (rootfolder)
end 
