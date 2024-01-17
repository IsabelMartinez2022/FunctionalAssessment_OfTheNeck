%Tasks 4, 5 and 6
%Average spectral power and duration of the spectrograms
%Statistical tests

average_groupA= spectralPower('GroupA');
average_groupB= spectralPower('GroupB');
[hypothesis_values_freq, p_values_freq,means,std_deviations]= analysis_frequency(average_groupA, average_groupB);

duration_groupA= durationSpectrogram('GroupA');
duration_groupB= durationSpectrogram('GroupB');
[hypothesis_value_duration, p_value_duration]= analysis_duration(duration_groupA,duration_groupB);


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
        %Sum of all three time series
        patient_xyz=abs(patient_x)+abs(patient_y)+abs(patient_z);
        
        %Power spectral densities are calculated using the spectrogram function for each band
        %Time series are centred
        patient_x_centred=patient_x-mean(patient_x);
        patient_y_centred=patient_y-mean(patient_y);
        patient_z_centred=patient_z-mean(patient_z);
        patient_xyz_centred=patient_xyz-mean(patient_xyz);

        [~,~,~,psx]= spectrogram(patient_x_centred,window_length,overlap,f,fs,"power",'yaxis');
        [~,~,~,psy]= spectrogram(patient_y_centred,window_length,overlap,f,fs,"power",'yaxis');
        [~,~,~,psz]= spectrogram(patient_z_centred,window_length,overlap,f,fs,"power",'yaxis');
        [~,~,~,psxyz]= spectrogram(patient_xyz_centred,window_length,overlap,f,fs,'yaxis');
        
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


function [hypothesis_values_freq,p_values_freq,means,std_deviations]= analysis_frequency(avg_groupA, avg_groupB)

h_groupA= zeros(4,11);
h_groupB= zeros(4,11);
hypothesis_values_freq= zeros(4,11);
p_values_freq= zeros(4,11);
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
            [p_values_freq(k,j),hypothesis_values_freq(k,j)]= ranksum(avg_groupA(:,j,k), avg_groupB(:,j,k));
        else 
            [hypothesis_values_freq(k,j),p_values_freq(k,j)]= ttest2(avg_groupA(:,j,k), avg_groupB(:,j,k));
        end 
        
        %We calculate mean and std deviation for those bands with
        %statistical differences between groups
        if hypothesis_values_freq(k,j)
            means(1,j,k)= mean(avg_groupA(:,j,k));
            means(2,j,k)= mean(avg_groupB(:,j,k));
            std_deviations(1,j,k)= std(avg_groupA(:,j,k));
            std_deviations(2,j,k)= std(avg_groupB(:,j,k));
        end 
       
    end
end
end


%Duration of the spectrograms 
function duration_patients= durationSpectrogram(groupname)

rootfolder = pwd;
addpath(rootfolder);
groupfolder= rootfolder+"\"+groupname+"_extracted\";
cd (groupfolder);

duration_patients= zeros(1,30);
index=1;

for i=1:200

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

cd (rootfolder)
end 


function [hypothesis_value_duration, p_value_duration]= analysis_duration(duration_groupA,duration_groupB)

%To check normality
h_groupA = adtest(duration_groupA);
h_groupB = adtest(duration_groupB);

%We perform t-test or Whitney-U-test based on normality assumptions
if h_groupA|| h_groupB
    [p_value_duration,hypothesis_value_duration]= ranksum(duration_groupA,duration_groupB);
else 
    [hypothesis_value_duration,p_value_duration]= ttest2(duration_groupA,duration_groupB);
end 
       
end
   