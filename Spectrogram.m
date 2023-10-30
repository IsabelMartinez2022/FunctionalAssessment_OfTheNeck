%Task 2
%Calculation of the spectrogram of each patient and saved as a png image

rootfolder= pwd;
groupAfolder= rootfolder+"\GroupA_extracted\";
cd (groupAfolder);

if not(isfolder("GroupA_spectrograms"))
mkdir("GroupA_spectrograms")
end

for i=1:200
    if isfile("Pte_"+i+"​_extracted.csv")
        read_data= readtable("Pte_"+i+"​_extracted.csv");
        read_data_array = table2array(read_data);
        %patient_xyz contains the Euler angles
        patient_xyz= str2double(strrep(read_data_array,',','.')); 
        
        %QUESTION: TRANSFORM TO QUATERNION??? 
        %patient_quaternion = eul2quat(patient_xyz,"XYZ");
        %With eul2quat()
        %With quatmultiply()
        %or slerp()

        fs= 50; %sampling rate of Unity's fixedUpdate()
        window_length = 256;
        overlap = window_length/2;
        nfft = 512;
      
        %Calculation of the spectrogram for each time series
        [s_x,f_x,t_x]=spectrogram(patient_xyz(:,1),window_length,overlap,nfft,fs);
        figure;
        subplot(3,1,1)
        waterplot(s_x,f_x,t_x);

        [s_y,f_y,t_y]=spectrogram(patient_xyz(:,2),window_length,overlap,nfft,fs);
        subplot(3,1,2)
        waterplot(s_y,f_y,t_y);
        
        [s_z,f_z,t_z]=spectrogram(patient_xyz(:,3),window_length,overlap,nfft,fs);
        subplot(3,1,3)
        waterplot(s_z,f_z,t_z);

        cd (groupAfolder+"\GroupA_spectrograms\");
        saveas(gcf,"Spectrogram_Patient"+i+".png");
        cd (groupAfolder);
    end 
end

groupBfolder= rootfolder+"\GroupB_extracted\";
cd (groupBfolder);

if not(isfolder("GroupB_spectrograms"))
mkdir("GroupB_spectrograms")
end

for j = 1:200
    if isfile("Pte_"+j+"​_extracted.csv")
        read_data= readtable("Pte_"+j+"​_extracted.csv");
        read_data_array = table2array(read_data);
        %patient_xyz contains the Euler angles
        patient_xyz= str2double(strrep(read_data_array,',','.')); 

        fs= 50; %sampling rate of Unity's fixedUpdate()
        window_length = 256;
        overlap = window_length/2;
        nfft = 512;
      
        %Calculation of the spectrogram for each time series
        [s_x,f_x,t_x]=spectrogram(patient_xyz(:,1),window_length,overlap,nfft,fs);
        figure;
        subplot(3,1,1)
        waterplot(s_x,f_x,t_x);

        [s_y,f_y,t_y]=spectrogram(patient_xyz(:,2),window_length,overlap,nfft,fs);
        subplot(3,1,2)
        waterplot(s_y,f_y,t_y);
        
        [s_z,f_z,t_z]=spectrogram(patient_xyz(:,3),window_length,overlap,nfft,fs);
        subplot(3,1,3)
        waterplot(s_z,f_z,t_z);

        cd (groupBfolder+"\GroupB_spectrograms\");
        saveas(gcf,"Spectrogram_Patient"+j+".png");
        cd (groupBfolder);
    end 
end

function waterplot(s,f,t)
% Waterfall plot of spectrogram from MatLab libreries
    waterfall(f,t,abs(s)'.^2);
    %Another option for the amplitude: 10 * log10(abs(s)')
    set(gca,XDir="reverse",View=[30 50])
    xlabel("Frequency (Hz)")
    ylabel("Time (s)")
end