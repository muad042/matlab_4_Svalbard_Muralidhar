%% PURPOSE
% example on how to calculate annual and seasonal statistics based on data from 
% calc_EURO_CORDEX_TEMP_monthly_NORWAY.m
% to take seasonal means will take a few minutes depending on the number of simulations
% the data is saved in a mat file (all models) and a text file (only ensemble stat) 
% required script: ksr.m to do the kernel smoothing

% select scenario
hist_scenario='historical'; 
future_scenario='rcp85'; 

% base years
base_syr=1971;
base_eyr=2000;

% seleced scenario period
% selected parameter
cordex_var='tas';

% frequency
frequency='mon'; 

% season
season=[1:1:12];    
% season=[12 1 2];
% season=[3 4 5];
% season=[6 7 8];
% season=[9 10 11];
% input directory
input_dir='/Data/skd/share/ModData3/CORDEX/EURO-CORDEX/EUR-11/NORWAY_mat/tas/rcp85/';
output_dir='/Home/siv5/sma087/Steffi/UNI_Klima/KSS/KiN2100/DATA/EUR-11/NORWAY/';

% Temperature regions 
region_names=['1 '; ...
              '2 '; ...
              '3 '; ...
              '4 '; ...
              '5 '; ...
              '6 '];
          
region_official_names=['Varanger           '; ...
                       'NordlandTroms      '; ...
                       'Finnmarksvidda     '; ...
                       'Trondelag          '; ...
                       'Vestlandet         '; ...
                       'Ostlandet          '];
          

% % temp regions
shape_file_regions='/Data/gfi/share/ObsData/DNMI_SHAPEFILES/tam-region';
   
% selected simulations
% GCMs
GCMs=['ICHEC-EC-EARTH   '; ...
      'ICHEC-EC-EARTH   '; ...
      'ICHEC-EC-EARTH   '; ...
      'ICHEC-EC-EARTH   '; ...
      'CERFACS-CNRM-CM5 '; ...
      'CERFACS-CNRM-CM5 '; ...
      'IPSL-CM5A-MR     '; ...
      'MOHC-HADGEM2-ES  '; ...
      'MPI-ESM-LR       '; ...
      'MPI-ESM-LR       '; ...
];

% Simulation number
model_runs=['r1i1p1 '; ...
            'r3i1p1 '; ...
            'r12i1p1'; ...
            'r12i1p1'; ...
            'r1i1p1 '; ...
            'r1i1p1 '; ...
            'r1i1p1 '; ...
            'r1i1p1 '; ...
            'r1i1p1 '; ...
            'r1i1p1 '; ...
];

% RCMs
RCMs=['RACMO22E   '; ...
      'HIRHAM5    '; ...
      'RCA4       '; ...
      'CCLM4-8-17 '; ...
      'RCA4       '; ...
      'CCLM4-8-17 '; ...
      'RCA4       '; ...
      'RCA4       '; ...
      'RCA4       '; ...
      'CCLM4-8-17 '; ...
];

no_simulations=size(GCMs,1);

% loop over simulations    
 for i=1:no_simulations
% load data made with calc_EURO_CORDEX_TEMP_monthly_NORWAY.m
     input_name=[input_dir deblank(upper(GCMs(i,:))) '_' deblank(model_runs(i,:)) '_' deblank(upper(RCMs(i,:)))  '_' deblank(cordex_var) '_' deblank(frequency) '_MONTHLY_' deblank(upper(hist_scenario)) '_and_' deblank(upper(future_scenario)) '_' num2str(season(1)) '_' num2str(season(end)) '_NORWAY'];
     disp(['plot_EURO_CORDEX_TEMP_seasonal_NORWAY_REGIONS: Reading: ' input_name])
     eval(['load ' input_name])

% put hist and future data together
     hist_future_cordex_data=[hist_cordex_data;future_cordex_data];
     hist_future_cordex_data_interp=[hist_cordex_data_interp';future_cordex_data_interp'];
     hist_future_cordex_ser_time=[hist_cordex_ser_time future_cordex_ser_time];
    
     
% ----------------
% select points inside Norway
% ----------------

% read shapefile with country boundaries
     shape_file_land='/Data/gfi/share/ObsData/WORLD_SHAPEFILES/cntry00';

% find Norway
     shape_no=250;
% % find Spain
%      shape_no=249;
     cntry_shape=shaperead(shape_file_land,'UseGeoCoords', false);
     lon_cntry=cntry_shape(shape_no).X;
     lat_cntry=cntry_shape(shape_no).Y;
     
% skip the islands
     nan_indx=[0 find(isnan(lon_cntry))];
     max_shape_indx=find(diff(nan_indx)==max(diff(nan_indx)));
     lon_cntry=lon_cntry(nan_indx(max_shape_indx)+1:nan_indx(max_shape_indx+1)-1);
     lat_cntry=lat_cntry(nan_indx(max_shape_indx)+1:nan_indx(max_shape_indx+1)-1);

% select points inside polygon
     hist_in_indx = inpolygon(hist_cordex_lon,hist_cordex_lat,lon_cntry,lat_cntry);
     hist_in_indx=find(hist_in_indx==1);
     future_in_indx = inpolygon(future_cordex_lon,future_cordex_lat,lon_cntry,lat_cntry);
     future_in_indx=find(future_in_indx==1);

% ----------------
% only save data inside polygon
     hist_cordex_lon=hist_cordex_lon(hist_in_indx);
     hist_cordex_lat=hist_cordex_lat(hist_in_indx);
     future_cordex_lon=future_cordex_lon(future_in_indx);
     future_cordex_lat=future_cordex_lat(future_in_indx);

     hist_future_cordex_data=hist_future_cordex_data(:,hist_in_indx);
  
 % select interpolated points inside polygon
     hist_in_indx_interp = inpolygon(cordex_lon,cordex_lat,lon_cntry,lat_cntry);
     hist_in_indx_interp=find(hist_in_indx_interp==1);
     future_in_indx_interp = inpolygon(cordex_lon,cordex_lat,lon_cntry,lat_cntry);
     future_in_indx_interp=find(future_in_indx_interp==1);

% ----------------
% only save interpolated data inside polygon
     cordex_lon_interp=cordex_lon(hist_in_indx_interp);
     cordex_lat_interp=cordex_lat(hist_in_indx_interp);
     hist_future_cordex_data_interp=hist_future_cordex_data_interp(:,hist_in_indx_interp);
     
% ----------------
% GRIDPOINT values
% ----------------

% seasonal means
missing_option=1;
data_treshold=0;
[hist_future_ser_time_mean_first_seasonal,hist_future_ser_time_mean_last_seasonal,hist_future_ser_time_mean_middle_seasonal,hist_future_data_mean_seasonal]=calc_seasonal_means(hist_future_cordex_ser_time,hist_future_cordex_data,season,data_treshold,missing_option);
[hist_future_ser_time_mean_first_interp_seasonal,hist_future_ser_time_mean_last_interp_seasonal,hist_future_ser_time_mean_middle_interp_seasonal,hist_future_data_mean_interp_seasonal]= calc_seasonal_means(hist_future_cordex_ser_time,hist_future_cordex_data_interp,season,data_treshold,missing_option);

% seasonal normal
[yr,mm,dd,hh,sec,minu]=datevec(hist_future_ser_time_mean_middle_seasonal);
base_indx=find(yr>=base_syr & yr<=base_eyr);
hist_future_data_mean_seasonal_normal=nanmean(hist_future_data_mean_seasonal(base_indx,:),1);
hist_future_data_mean_interp_seasonal_normal=nanmean(hist_future_data_mean_interp_seasonal(base_indx,:),1);

% seasonal anomalies
hist_future_data_mean_seasonal_anom=hist_future_data_mean_seasonal-repmat(hist_future_data_mean_seasonal_normal,size(hist_future_data_mean_seasonal,1),1);
hist_future_data_mean_interp_seasonal_anom=hist_future_data_mean_interp_seasonal-repmat(hist_future_data_mean_interp_seasonal_normal,size(hist_future_data_mean_interp_seasonal,1),1); 

% ----------------
% get data for Norway
% ----------------
        if i==1
           t_dim_max=length(hist_future_ser_time_mean_middle_seasonal);
        end
        t_dim=length(hist_future_ser_time_mean_middle_seasonal);
        hist_future_data_mean_interp_seasonal_norway(i,1:t_dim_max)=NaN;
       [hist_future_data_mean_interp_seasonal_norway(i,1:t_dim)]= calc_CORDEX_area_avg(cordex_lat_interp,cordex_lon_interp,hist_future_data_mean_interp_seasonal',0.1);
       
% normal       
       hist_future_data_mean_interp_seasonal_normal_norway(i)=nanmean(hist_future_data_mean_interp_seasonal_norway(i,base_indx)');
if strcmp(cordex_var,'tas')       
% seasonal anomalies
    hist_future_data_mean_interp_seasonal_anom_norway(i,:)=hist_future_data_mean_interp_seasonal_norway(i,:)-hist_future_data_mean_interp_seasonal_normal_norway(i);

       
%% precip change
else
% relative difference between future and hist
    hist_future_data_mean_interp_seasonal_anom_norway2(i,:)=(hist_future_data_mean_interp_seasonal_anom_norway(i,:)./hist_future_data_mean_interp_seasonal_normal_norway(i)).*100;
end
%% Kernel smoothing
       h=9;n=130;mod_years=1971:2100;
       ts_anom_norway(i)=ksr(mod_years,hist_future_data_mean_interp_seasonal_anom_norway(i,:),h,n);
 
 end 
for i=1:no_simulations
  X(i,:)=ts_anom_norway(i).f;
end
% ----------------
% calculate ensemble statistics
% ----------------
% ensemble median
ts_anom_norwayM=prctile(X,50);

% ensemble 10 PRCTILE
ts_anom_norwayL=prctile(X,10);

% ensemble 90 PRCTILE
ts_anom_norwayH=prctile(X,90);

% years
hist_future_years=str2num(datestr(hist_future_ser_time_mean_middle_seasonal,10));

% list of models
model_list='';
 for k=1:no_simulations
     if k==1
         list1=[deblank(GCMs(k,:)) '_' deblank(model_runs(k,:)) '_' deblank(RCMs(k,:))];
     else
         list1=[', ' deblank(GCMs(k,:)) '_' deblank(model_runs(k,:)) '_' deblank(RCMs(k,:))];
     end
     model_list=[model_list list1];
 end
 
 % season
if season(1)==12 & season(end)==2
            season_txt='djf   ';
        elseif season(1)==3 & season(end)==5
            season_txt='mam   ';
        elseif season(1)==6 & season(end)==8
            season_txt='jja   ';
        elseif season(1)==9 & season(end)==11
            season_txt='son   ';
        elseif season(1)==1 & season(end)==12
            season_txt='ann   ';
end
        

%-----------------------------------------------------------------
% make mat file with ensemble changes and all models annual precip for Norway and all regions
%-----------------------------------------------------------------

output_file=[output_dir upper(cordex_var) '_' deblank(upper(hist_scenario)) '_' deblank(upper(future_scenario)) '_' num2str(hist_start_year) '_' num2str(future_end_year) '_'  upper(deblank(season_txt)) '_KERNEL_SMOOTHED_h9.mat'];

eval(['save ' output_file ' region_official_names season season_txt GCMs model_runs RCMs hist_cordex_data_longname hist_scenario future_scenario cordex_var frequency hist_years future_years hist_start_year hist_end_year future_start_year future_end_year hist_cordex_data_unit  hist_future_years ts_anom_norwayM ts_anom_norwayL ts_anom_norwayH']);



%-----------------------------------------------------------------
% make text file with ensemble changes in annual precip for Norway and all regions
%-----------------------------------------------------------------

output_file=[output_dir upper(cordex_var) '_' deblank(upper(hist_scenario)) '_' deblank(upper(future_scenario)) '_' num2str(hist_start_year) '_' num2str(future_end_year) '_'  upper(deblank(season_txt)) '_KERNEL_SMOOTHED_h9.txt'];

header_txt1=['            NORWAY  kernel smoothed values                 ']; 
            
header_txt2=['-----------------------------------------------------------'];
header_txt3=['YEAR      MEDIAN   10PR   90PR   '];  
                        
 
    h4=['DESCRIPTION                : ORG. DATA FROM EURO CORDEX 12 km DATASET'];
    h5=['                           : GRIDPNTS WITHIN THE REGION ARE SELECTED'];
    h6=['HISTORICAL SCENARIO        : ' upper(hist_scenario)];
    h7=['CNTRL START YEAR           : ' num2str(hist_start_year)];
    h8=['CNTRL END YEAR             : ' num2str(hist_end_year)];
    h9=['FUTURE SCENARIO            : ' upper(future_scenario)];
    h10=['SCENARIO START YEAR        : ' num2str(future_start_year)];
    h11=['SCENARIO END YEAR          : ' num2str(future_end_year)];
    h12=['NORMAL START YEAR          : ' num2str(base_syr)];
    h13=['NORMAL END YEAR            : ' num2str(base_eyr)];
    h14=[' '];
    h15=['VARIABLE                   : ' upper(cordex_var)];
    h15=['SEASON                     : ' upper(season_txt)];
    h16=['ACCUMULATION               : ' 'MONTHLY'];
    h17=['ENSEMBLE METHOD            : ' 'EQUAL WEIGHT ON EACH SIMULATION'];
    h18=['NO. OF SIMULATIONS         : ' num2str(no_simulations)];
    h19=['SIMULATION LIST            : ' model_list];
   
    h33=['COL 1                      : YEAR'];
   
    h35=['COL 3                      :  ENS. MEDIAN        [SCEN-CNTRL] (K)'];
    h36=['COL 4                      :  ENS. 10 PRECENTILE [SCEN-CNTRL] (K)'];
    h37=['COL 5                      :  ENS. 90 PRECENTILE [SCEN-CNTRL] (K)'];
    
    h38=[' '];
    h39=[header_txt1];
    h40=[header_txt2];
    h41=[header_txt3];
    
    
    fid = fopen(output_file,'w');
    
    fprintf(fid,'%s\n',h4);         
    fprintf(fid,'%s\n',h5);         
    fprintf(fid,'%s\n',h6);         
    fprintf(fid,'%s\n',h7);         
    fprintf(fid,'%s\n',h8);         
    fprintf(fid,'%s\n',h9);         
    fprintf(fid,'%s\n',h10);         
    fprintf(fid,'%s\n',h11);         
    fprintf(fid,'%s\n',h12);         
    fprintf(fid,'%s\n',h13);         
    fprintf(fid,'%s\n',h14);         
    fprintf(fid,'%s\n',h15);         
    fprintf(fid,'%s\n',h16);         
    fprintf(fid,'%s\n',h17);         
    fprintf(fid,'%s\n',h18);                
%         
    fprintf(fid,'%s\n',h33);         
        
    fprintf(fid,'%s\n',h35);         
    fprintf(fid,'%s\n',h36);         
    fprintf(fid,'%s\n',h37);         
    fprintf(fid,'%s\n',h38);         
    fprintf(fid,'%s\n',h39);         
    fprintf(fid,'%s\n',h40);         
    fprintf(fid,'%s\n',h41);         
   
    
for mm=1:length(hist_future_years)
% read Norwegian data
     table_data_Norway=[hist_future_years(mm), ...
             ts_anom_norwayM(mm), ...
             ts_anom_norwayL(mm), ...
             ts_anom_norwayH(mm)];
             fprintf(fid,'%7.0f%7.2f%7.2f%7.2f\n',table_data_Norway');


end

 fclose(fid);