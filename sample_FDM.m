%% Sample Code for Frame-Differencing Method  %%

% This code generates time series of movement through the frame-differencing method 
% described in the article, "Frame-Differencing Methods for Measuring Bodily Synchrony in 
% Conversation" (Paxton & Dale, 2013; Behavior Research Methods). This paper was supported
% by the National Science Foundation under grants [BCS-0826825 and BCS-0926670].

% Be sure to save this text file as a .m file before use!

%% PROCESSING LOOP % PROCESSING LOOP % PROCESSING LOOP % PROCESSING LOOP %

% insert appropriate directory below
cd('directory');

% basic variables
h = gcf;
win_size = 150;

% fetch images
imgpath = 'img_*.jpg';
imgfiles = dir(imgpath);
disp(['Found ' int2str(length(imgfiles)) ' image files.'])

% create vectors for differenced image z-scores and L/R movement scores 
image_z_diffs = [];
pLms = [];
pRms = [];

% begin loop through images
for j=2:length(imgfiles)
     disp(['Processing image: ' int2str(j) '.']);  

     % prep the files
     file_name = imgfiles(j).name;
     image_2 = imread(file_name);
     file_name = imgfiles(j-1).name;
     image_1 = imread(file_name);

     % collapse images across color
     image_2 = mean(image_2,3);
     image_1 = mean(image_1,3);    

     % turn images into pixel z-scores
     image_2 = (image_2 - mean(image_2(:)))./std(double(image_2(:)));
     image_1 = (image_1 - mean(image_1(:)))./std(double(image_1(:)));   

     % difference, standardize, and store difference vectors
     image_diff = abs(image_2 - image_1);
     image_z_diffs = [image_z_diffs ; mean(image_diff(:))];

     % split images into L/R
     pLm = mean(mean(mean(image_diff(:,1:320,:)))); % change pixels as needed to half image
     pRm = mean(mean(mean(image_diff(:,321:end,:)))); % see above    

     % store split vectors
     pLms = [pLms ; pLm];
     pRms = [pRms ; pRm];
end  

% apply Butterworth filter to results
[bb,aa] = butter(2,.2); 
pLms = filter(bb,aa,pLms);
pRms = filter(bb,aa,pRms);  

% get pLms/pRms vectors in text output
eval('save FDM_pLms pLms -ascii -tabs'); 
eval('save FDM_pRms pRms -ascii -tabs');  

% save workspace 
save sample_FDM.mat;
disp('Frame-Differencing for Sample Dyad Complete.')

% CALCULATE CORRELATIONS % CALCULATE CORRELATIONS % CALCULATE CORRELATIONS %  

% create matrix for correlations
dy_xcorrs = []; 
disp('Creating Correlations for Sample Dyad.')  

% cross-correlate and fill matrix
dy_xcorr = xcov(pLms,pRms,win_size,'coeff'); 
dy_xcorrs = [dy_xcorrs  dy_xcorr]; 
disp('Cross-Correlations for Sample Dyad Complete.')  

% save workspace 
save sample_FDM.mat 
disp('MATLAB Workspace Saved.')  

% GENERATE TEXT FILE % GENERATE TEXT FILE % GENERATE TEXT FILE %  

% create csv file 
delete('sample.FDM.csv'); 
data_out = fopen('sample.FDM.csv ','w'); 
disp('Text File Created.')  

% fill the file with data 
for x_corr=1:301
     % cross-correlation coefficients
     fprintf(data_out,'%d,',eval(['dy_xcorrs(' int2str(x_corr) ')']));
  
     % time slice
     fprintf(data_out,'%d,',x_corr);                  
end  

% close the data file 
fclose(data_out); 
disp('Text File Complete.');
