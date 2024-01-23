%Tasks 4, 5 and 6
%Average spectral power and duration of the spectrograms
%Statistical tests

power_bands_groupA= spectralPower('GroupA');
power_bands_groupB= spectralPower('GroupB');
[power_range_groupA, power_range_groupB]= spectralPower_range(power_bands_groupA, power_bands_groupB);
[hypothesis_values_freqbands, p_values_freqbands,means_bands,stddev_bands]= analysis_freq_bands(power_bands_groupA, power_bands_groupB);
[hypothesis_values_range, p_values_range,mean_range,stddev_range]= analysis_freq_range(power_range_groupA, power_range_groupB);

duration_groupA= durationSpectrogram('GroupA');
duration_groupB= durationSpectrogram('GroupB');
[hypothesis_value_duration, p_value_duration, mean_duration, stddev_duration]= analysis_duration(duration_groupA,duration_groupB);


%Contains the avg spectral power for all 4 measurements (x,y,z,total), 
%in all 11 frequency bands, for all 30 group patients
function [power_bands, power_range]= spectralPower (groupname)

window_length =256;
overlap = 128;
f=[0, 0.5, 1, 3, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25];
length_freqbands=length(f);

power_bands=zeros(30,length_freqbands,4);
power_range=zeros(30,2,4);
patient_index=1;

rootfolder = pwd;
addpath(rootfolder);
groupfolder= rootfolder+"\"+groupname+"_extracted\";
cd (groupfolder);

for i=1:200

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

        [~,~,~,psx_band]= spectrogram(patient_x_centred,window_length,overlap,f,fs,"power",'yaxis');
        [~,~,~,psy_band]= spectrogram(patient_y_centred,window_length,overlap,f,fs,"power",'yaxis');
        [~,~,~,psz_band]= spectrogram(patient_z_centred,window_length,overlap,f,fs,"power",'yaxis');
        [~,~,~,psxyz_band]= spectrogram(patient_xyz_centred,window_length,overlap,f,fs,'yaxis');

        
        %Average in each band
        power_bands(patient_index,:,1)= mean(psx_band,2);
        power_bands(patient_index,:,2)= mean(psy_band,2);
        power_bands(patient_index,:,3)= mean(psz_band,2);
        power_bands(patient_index,:,4)= mean(psxyz_band,2);

        patient_index=patient_index+1;
    end 
end

cd (rootfolder)
end 


%Also, total average spectral power in [0,0.5] and [0.5, 25]
function [power_range_groupA, power_range_groupB]=spectralPower_range(avg_groupA, avg_groupB)

f=[0, 0.5, 1, 3, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25];
power_range_groupA= zeros(30,2,4);
power_range_groupB= zeros(30,2,4);

%Group A
for patient_index= 1:30
    for mov_index= 1:4
        
        %Total power for the first band range
        power_range_groupA(patient_index,1,mov_index) = avg_groupA(patient_index,1,mov_index)+avg_groupA(patient_index,2,mov_index);
        %Total power for the second band range
        for band_index=2:length(f)
        power_range_groupA(patient_index,2,mov_index) = power_range_groupA(patient_index,2, mov_index)+avg_groupA(patient_index,band_index,mov_index);
        end
    end
end

%Group B
for patient_index= 1:30
    for mov_index= 1:4
        
        %Total power for the first band range
        power_range_groupB(patient_index,1,mov_index) = avg_groupB(patient_index,1,mov_index)+avg_groupB(patient_index,2,mov_index);
        %Total power for the second band range
        for band_index=2:length(f)
        power_range_groupB(patient_index,2,mov_index) = power_range_groupB(patient_index,2, mov_index)+avg_groupB(patient_index,band_index,mov_index);
        end
    end
end

end


function [hypothesis_bands,p_values_bands,mean_bands,stddev_bands]= analysis_freq_bands(avg_groupA, avg_groupB)

f=[0, 0.5, 1, 3, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25];
length_freqbands=length(f);

h_groupA= zeros(4,length_freqbands);
h_groupB= zeros(4,length_freqbands);
hypothesis_bands= zeros(4,length_freqbands);
p_values_bands= zeros(4,length_freqbands);
mean_bands=zeros(2,length_freqbands,4);
stddev_bands=zeros(2,length_freqbands,4);

%Loop through each measurement
for k = 1:4 
    %Loop through each frequency band for all patients
    for j = 1:length_freqbands 

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
            [p_values_bands(k,j),hypothesis_bands(k,j)]= ranksum(avg_groupA(:,j,k), avg_groupB(:,j,k));
        else 
            [hypothesis_bands(k,j),p_values_bands(k,j)]= ttest2(avg_groupA(:,j,k), avg_groupB(:,j,k));
        end 
        
        %We calculate mean and std deviation for those bands with
        %statistical differences between groups
        mean_bands(1,j,k)= mean(avg_groupA(:,j,k));
        mean_bands(2,j,k)= mean(avg_groupB(:,j,k));
        stddev_bands(1,j,k)= std(avg_groupA(:,j,k));
        stddev_bands(2,j,k)= std(avg_groupB(:,j,k));       
    end
end
end


function [hypothesis_range,p_values_range,mean_range,stddev_range]= analysis_freq_range(power_groupA, power_groupB)

h_groupA= zeros(4,2);
h_groupB= zeros(4,2);
hypothesis_range= zeros(4,2);
p_values_range= zeros(4,2);
mean_range=zeros(2,2,4);
stddev_range=zeros(2,2,4);

%Loop through each measurement
for k = 1:4 
    %Loop through each frequency range for all patients
    for j = 1:2 

        %To check normality
        h_groupA(k,j) = adtest(power_groupA(:,j,k));
        h_groupB(k,j) = adtest(power_groupB(:,j,k));

        %We perform t-test or Whitney-U-test based on normality assumptions
        if h_groupA(k,j)|| h_groupB(k,j)
            [p_values_range(k,j),hypothesis_range(k,j)]= ranksum(power_groupA(:,j,k), power_groupB(:,j,k));
        else 
            [hypothesis_range(k,j),p_values_range(k,j)]= ttest2(power_groupA(:,j,k), power_groupB(:,j,k));
        end 
        
        %We calculate mean and std deviation for those bands with
        %statistical differences between groups
        mean_range(1,j,k)= mean(power_groupA(:,j,k));
        mean_range(2,j,k)= mean(power_groupB(:,j,k));
        stddev_range(1,j,k)= std(power_groupA(:,j,k));
        stddev_range(2,j,k)= std(power_groupB(:,j,k));       
    end
end
end
%}

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


function [hypothesis_value_duration, p_value_duration, mean_duration, stddev_duration]= analysis_duration(duration_groupA,duration_groupB)

mean_duration= zeros(2,1);
stddev_duration= zeros(2,1);

%To check normality
h_groupA = adtest(duration_groupA);
h_groupB = adtest(duration_groupB);

%We perform t-test or Whitney-U-test based on normality assumptions
if h_groupA|| h_groupB
    [p_value_duration,hypothesis_value_duration]= ranksum(duration_groupA,duration_groupB);
else 
    [hypothesis_value_duration,p_value_duration]= ttest2(duration_groupA,duration_groupB);
end 

mean_duration(1)=mean(duration_groupA);
mean_duration(2)=mean(duration_groupB);
stddev_duration(1)=std(duration_groupA);
stddev_duration(2)=std(duration_groupB);
   
end
   