%Task 2
%Calculation of the spectrogram of each patient and saved as a png image
%The position of the stored appears in the same graph

createSpectrogram('GroupA');
createSpectrogram('GroupB');

function createSpectrogram (groupname)

rootfolder = pwd;
groupfolder= rootfolder+"\"+groupname+"_extracted\";
cd (groupfolder);

if not(isfolder(groupname+"_spectrograms"))
mkdir(groupname+"_spectrograms")
end

for i=1:200
    if isfile("Pte_"+i+"​_extracted.csv")
        read_data= readtable("Pte_"+i+"​_extracted.csv");

        read_data.Var3 = string(read_data.Var3);
        read_data.Var1 = num2str(read_data.Var1);
        %Array containing all interesting data
        read_data_array = table2array(read_data);

        %Rows not containing information about the stored apples
        rowsEuler= ~contains(read_data_array(:, 3), "stored");
        %Rows containing information about the stored apples
        rowsApples= contains(read_data_array(:, 3), "stored");
        %patient_xyz contains the Euler angles
        patient_xyz= str2double(strrep(read_data_array(rowsEuler,:),',','.')); 
        %samples_storedApples contains the samples when an apple was stored
        samples_storedApples= str2double(strrep(read_data_array(rowsApples,1:2),',','.'));

        fs= 50; %sampling rate of Unity's fixedUpdate()
        window_length = 256;
        overlap = window_length/2;
        nfft=256;
      
        %Calculation of the spectrogram for each time series
        %We substract the neutral positions (first row angles)
        
        figure;
        subplot(3,1,1)
        spectrogram(patient_xyz(:,4)-patient_xyz(1,4),window_length,overlap,nfft,fs,'yaxis');
        % We also add a vertical line for each time sample 
        %time_storedApples = samples_storedApples(:,2) * (window_length - overlap) / fs;
        time_storedApples = samples_storedApples(:, 2);
        hold on;
        for index = 1:length(time_storedApples)
        line([time_storedApples(index), time_storedApples(index)], ylim, 'Color', 'r', 'LineWidth', 1);
        end
        %hold off;
        %waterplot(s_x,f_x,t_x);

        subplot(3,1,2);
        spectrogram(patient_xyz(:,5)-patient_xyz(1,5),window_length,overlap,nfft,fs,'yaxis');
        hold on;
        for index = 1:length(time_storedApples)
        line([time_storedApples(index), time_storedApples(index)], ylim, 'Color', 'r', 'LineWidth', 1);
        end
        %hold off;
        %waterplot(s_y,f_y,t_y);

        subplot(3,1,3);
        spectrogram(patient_xyz(:,6)-patient_xyz(1,6),window_length,overlap,nfft,fs,'yaxis');
        hold on;
        for index = 1:length(time_storedApples)
        line([time_storedApples(index), time_storedApples(index)], ylim, 'Color', 'r', 'LineWidth', 1);
        end
        hold off;
        %waterplot(s_z,f_z,t_z);
        
        % We also add a vertical line for each sample in samples_storedApples
        
        %{
        for index = 1:length(samples_storedApples)
        y=ylim;
        
        subplot(3,1,1);
        hold on;
        line(samples_storedApples(index,2), y, 'Color', 'r', 'LineWidth', 1);

        subplot(3,1,2);
        hold on;
        line([samples_storedApples(index), samples_storedApples(index)], ylim, 'Color', 'r', 'LineWidth', 1);

        subplot(3,1,3);
        hold on;
        line([samples_storedApples(index), samples_storedApples(index)], ylim, 'Color', 'r', 'LineWidth', 1);
        end
        %}

        cd (groupfolder+"\"+groupname+"_spectrograms\");
        saveas(gcf,"Spectrogram_Patient"+i+".png");
        close(gcf);
        cd (groupfolder);
    end 
end
cd (rootfolder)

end 
