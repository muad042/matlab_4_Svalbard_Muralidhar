%% PURPOSE
% example on how to retrive cordex data for chosen parameter make an
% ensemble mean and plot the data on a common lat-lon grid.
% This script makes figures presented in KiN2100, Figures A.5.2.1-A.5.2.4
% and A.5.2.5-A.5.2.6

% required scripts:
% CORDEX_check_data_existence.m: make sure you define all simulations (GCM, sim, and RCM) in this script 
% calc_seasonal_means.m
% CORDEX_pcolor_plot.m: makes the figure
% ...
% Modified by Muralidhar Adakudlu for Arctic CORDEX
% Included couple of lines for estimating mean statistics and writing to a
% text file for box plots - Nov 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; close all; 

% selected 
language='E';% the alternative is Norwegian
hist_scenario='historical'; 
future_scenario='RCP85'; 
cordex_var='tas';
frequency='mon'; 

% start and end years
hist_start_year=1970; hist_end_year=2005; 
future_start_year=2071; future_end_year=2100; 

% If you change one of the following parameters, put FirstTime = 1.
% future_scenario; cordex_var; period
FirstTime = 0;

% selected region 
polygon_lon=[5; 37; 37; 5; 5 ]; polygon_lat=[76.2; 76.2; 81.4; 81.4;76.2];% Svalbard 
nw_corner=[min(polygon_lon) max(polygon_lat)]; se_corner=[max(polygon_lon) min(polygon_lat)];

% selected season
data_treshold=0;
missing_option=1;
%  season=1:1:12; seas='ANN';
%  season=[12 1 2]; seas='DJF';
%  season=[3 4 5]; seas = 'MAM';
  season=[6 7 8]; seas = 'JJA';
%  season=[9 10 11]; seas = 'SON';
 
% New common grid to store the data
    dlon=.44;
    dlat=.44;
    cordex_lon=nw_corner(1):dlon:se_corner(1);
    cordex_lat=se_corner(2):dlat:nw_corner(2);
    xdim=length(cordex_lon);
    ydim=length(cordex_lat);
    [cordex_lon,cordex_lat]=meshgrid(cordex_lon,cordex_lat);
    lon_grid = cordex_lon;
    lat_grid = cordex_lat;
    cordex_lon=reshape(cordex_lon,1,ydim*xdim);
    cordex_lat=reshape(cordex_lat,1,ydim*xdim);
  
% ----------------------------
% find models that have data for both historical and future run
% ----------------------------

%% historical
[hist_CORDEX_directory,hist_GCMs,hist_model_runs,hist_RCMs,hist_data_exist_flag,hist_models_with_all_data,hist_models_with_some_data]...
    =CORDEX_check_data_existence(cordex_var,hist_scenario,frequency,hist_start_year,hist_end_year);

% get models that have data for whole or part of the requested period
indx=find(hist_data_exist_flag<2);
GCMs=hist_GCMs(indx,:);
model_runs=hist_model_runs(indx,:);

% ----------------------------
% get data for selected models and simulations
% ----------------------------
no_simulations=size(GCMs,1);
% ----------------
% loop over all simulations for all models
% ----------------
for i=1:no_simulations   

% ----------------
% historical
% ----------------
% Get the directory corresponding to an existing RCM --- added by
% Muralidhar

    hist_CORDEX_directory = ['/media/mad042/My Passport/Data/CORDEX/' deblank(hist_scenario) '/' deblank(cordex_var) '/' deblank(frequency) '/' deblank(hist_GCMs(i,:))  '/' deblank(hist_model_runs(i,:)) '/' deblank(hist_RCMs(i,:))  '/';];

    disp(hist_CORDEX_directory)
    
% read the data
    [hist_cordex_lat,hist_cordex_lon,hist_cordex_lat_grid,hist_cordex_lon_grid,hist_cordex_ser_time,hist_cordex_time_calendar,hist_cordex_time_check_flag,hist_cordex_data,hist_cordex_data_longname,hist_cordex_data_unit,hist_cordex_start_year,hist_cordex_end_year]...
        =read_CORDEX_2D_data(hist_CORDEX_directory,hist_scenario,cordex_var,frequency,GCMs,hist_start_year,hist_end_year,polygon_lon,polygon_lat);
                     
% calculate seasonal means
    [hist_ser_time_mean_first,hist_ser_time_mean_last,hist_ser_time_mean_middle,hist_data_mean]...
        =calc_seasonal_means(hist_cordex_ser_time,hist_cordex_data,season,data_treshold,missing_option);      % hist_ser_time_mean_middle: middle of a season, ie., July for annual mean

% calculate mean over all seasons
    hist_nonans=find(~isnan(hist_data_mean(:,1)));
    hist_cordex_data_timemean=mean(hist_data_mean(hist_nonans,:),1)';                                        % Seasonal/annual climatology
    hist_cordex_ser_time_timemean=hist_ser_time_mean_middle(round(length(hist_ser_time_mean_middle)/2));     % Middle year of the time span, i.e., 1995 for 1981-2010

% interpolate to a common grid using nearest neighbour interpolation
% NOTE: this take some time if the region is large and the grid resolution is high
%    hist_cordex_lon=reshape(hist_cordex_lon,1,[]);
%    hist_cordex_lat=reshape(hist_cordex_lat,1,[]);
   [hist_cordex_data_timemean_interp]=interpolate_nearest(hist_cordex_lat,hist_cordex_lon,hist_cordex_data_timemean,cordex_lat,cordex_lon);
   
   % save data in a common array
   hist_cordex_data_timemean_interp_all(:,i)=hist_cordex_data_timemean_interp;
end

% ----------------
% Future
% ----------------

[future_CORDEX_directory,future_GCMs,future_model_runs,future_RCMs,future_data_exist_flag,future_models_with_all_data,future_models_with_some_data]...
    =CORDEX_check_data_existence(cordex_var,future_scenario,frequency,future_start_year,future_end_year); 

indx=find(future_data_exist_flag<2);
GCMs=future_GCMs(indx,:);
model_runs=future_model_runs(indx,:);

% ----------------------------
% get data for selected models and simulations
% ----------------------------
no_simulations=size(GCMs,1);

% ----------------
% loop over all simulations for all models
% ----------------

for i=1:no_simulations

    future_CORDEX_directory = ['/media/mad042/My Passport/Data/CORDEX/' deblank(future_scenario) '/' deblank(cordex_var) '/' deblank(frequency) '/' deblank(future_GCMs(i,:))  '/' deblank(future_model_runs(i,:)) '/' deblank(future_RCMs(i,:))  '/';];

% read the data
   [future_cordex_lat,future_cordex_lon,future_cordex_lat_grid,future_cordex_lon_grid, future_cordex_ser_time,future_cordex_time_calendar,future_cordex_time_check_flag,future_cordex_data,future_cordex_data_longname,future_cordex_data_unit,future_cordex_start_year,future_cordex_end_year]...
       =read_CORDEX_2D_data(future_CORDEX_directory,future_scenario,cordex_var,frequency,GCMs,future_start_year,future_end_year,polygon_lon,polygon_lat);
 
% calculate seasonal means
   [future_ser_time_mean_first,future_ser_time_mean_last,future_ser_time_mean_middle,future_data_mean]...
      =calc_seasonal_means(future_cordex_ser_time,future_cordex_data,season,data_treshold,missing_option);

% calculate mean over all seasons
   future_nonans=find(~isnan(future_data_mean(:,1)));
   future_cordex_data_timemean=mean(future_data_mean(future_nonans,:),1)';
   future_cordex_ser_time_timemean=future_ser_time_mean_middle(round(length(future_ser_time_mean_middle)/2));
    
% interpolate to a common grid using nearest neighbour interpolation
% NOTE: this takes some time if the region is large and the grid resolution
% is high
   future_cordex_lon=reshape(future_cordex_lon,1,[]);
   future_cordex_lat=reshape(future_cordex_lat,1,[]);
   [future_cordex_data_timemean_interp]=interpolate_nearest(future_cordex_lat,future_cordex_lon,future_cordex_data_timemean,cordex_lat,cordex_lon);

   % save data in a common array
   future_cordex_data_timemean_interp_all(i,:)=future_cordex_data_timemean_interp;
   disp(num2str(nanmean(future_cordex_data_timemean_interp)))
end

% Ensemble mean/median from the historical
hist_cordex_ENS_median=nanmedian(hist_cordex_data_timemean_interp_all,2)';

% anomaly (future ensemble median minus historical ensemble median) 
anom_cordex_ENS_median=nanmedian(future_cordex_data_timemean_interp_all,1)-hist_cordex_ENS_median;

% relative difference between future and hist
if ( strcmp(cordex_var,'pr') || strcmp(cordex_var,'sic') )
    reldiff_cordex_ENS_median=(anom_cordex_ENS_median./hist_cordex_ENS_median)*100;
end

% Muralidhar - mask out the data over ocean. 
% Used for area averaging and box plots
shape_no=2;
shape_file_land='/scratch/WORLD_SHAPEFILES/cntry00';
cntry_shape=shaperead(shape_file_land,'UseGeoCoords', false);
lon_cntry=cntry_shape(shape_no).X;
lat_cntry=cntry_shape(shape_no).Y;

inside=inpolygon(cordex_lon,cordex_lat,lon_cntry,lat_cntry);

% median, min and max through the ensembles - Muralidhar
a                      = future_cordex_data_timemean_interp_all(:,inside) ;
b                      = nanmedian(hist_cordex_data_timemean_interp_all(inside,:),2)';
data                   = bsxfun(@minus,a,b);  % absolute change
if ( strcmp(cordex_var,'pr') || strcmp(cordex_var,'sic') )
    rel_change             = bsxfun(@rdivide,data,b)*100;  
    clear data; data       = rel_change;
end    

med_anom_cordex_ENS    = nanmedian(data,1);
min_anom_cordex_ENS    = min(data,[],1);
max_anom_cordex_ENS    = max(data,[],1);
mean_anom_cordex_ENS   = nanmean(data,1); %nanmean(hist_cordex_ENS_norm(inside)-273.16);
anom_cordex_ENS_10     = prctile(data,10,1);
anom_cordex_ENS_90     = prctile(data,90,1);

if strcmp(cordex_var,'pr')
  unit = 90;    % seasonal; for annual values, unit = 365
  disp(['Mean   = ', num2str(nanmean(mean_anom_cordex_ENS)*86400*unit,'%4.3d')]);
  disp(['Median = ', num2str(nanmean(med_anom_cordex_ENS)*86400*unit,'%4.3d')]);
  disp(['10 %   = ', num2str(nanmean(anom_cordex_ENS_10)*86400*unit,'%4.3d')]);
  disp(['90 %   = ', num2str(nanmean(anom_cordex_ENS_90)*86400*unit,'%4.3d')]);
end

% ----------------
% Plotting
% ----------------

if strcmp(cordex_var,'pr')
    plot_data=reldiff_cordex_ENS_median;
    %plot_data = hist_cordex_ENS_median*86400*unit ;
    if strcmp(language,'E')
        plot_unit='relative precipitation change [%]';
         %plot_unit='Precipitation change (mmday^{-1})';
    else
        plot_unit='Nedbør endring [%]';
    end
    %plot_unit='Precipitation change [mm]';
    color_scheme='GMT_drywet';
    color_interval=-10:2.5:100;
    %color_interval=0:10:200;
    add_zeroline=0;
    add_clines=[-50  50];
    mask='';
    contour_type='filled';

elseif strcmp(cordex_var,'tas')
    plot_data=hist_cordex_ENS_median-273.16; 
    %plot_data=anom_cordex_ENS_median;
    if strcmp(language,'E')
        plot_unit='Temperature change [^oC]';
    else
        plot_unit='Temperatur endring [^oC]';
    end
    %color_scheme='blue';
    color_scheme='GMT_globe';
    %color_scheme='BlueRed';
    %color_interval=-26:2:2;
    color_interval=-1:1:20;
    add_zeroline=0;
    add_clines=[-15 15];
    mask='';
    contour_type='pcolor';

elseif strcmp(cordex_var,'sic')
    plot_data= reldiff_cordex_ENS_median;
    if strcmp(language,'E')
        plot_unit='sea ice concentration [%]';
    else
        plot_unit='Temperatur endring [^oC]';
    end
    %color_scheme='blue';
    %color_scheme='GMT_globe';
    color_scheme='BlueRed';
    %color_interval=-100:1:-90;
    add_zeroline=0;
    add_clines=[-15 15];
    mask='';
    contour_type='pcolor';
    
end

colorbar_location='SouthOutside';
prnt='png';

output_name=['median_kart_' deblank(cordex_var) '_' deblank(hist_scenario) '_months_' num2str(season(1)) 'to' num2str(season(end)) '_' num2str(hist_start_year) '_to_' num2str(hist_end_year)];
%output_name=['median_kart_' deblank(cordex_var) '_' deblank(future_scenario) '_months_' num2str(season(1)) 'to' num2str(season(end)) '_' num2str(future_start_year) '_to_' num2str(future_end_year)];
proj='lambert';

%% map text
map_text=[];

%% plot    
CORDEX_pcolor_plot(cordex_lat,cordex_lon,plot_data,proj,nw_corner,se_corner,color_interval,color_scheme,contour_type,add_zeroline,add_clines,mask,map_text,plot_unit,colorbar_location,prnt,output_name,language,seas,nanmean(plot_data))

%% SMOOTHING... YES or NO? 
% no_x = length(unique(cordex_lon));
% no_y = length(unique(cordex_lat));
% cordex_lon = reshape(cordex_lon,no_y,no_x);
% cordex_lat = reshape(cordex_lat,no_y,no_x); 
% plot_data= reshape(plot_data,no_y,no_x);
% 
% smoothing_param=.2;
% plot_data_smooth=smoothn(plot_data,smoothing_param,'robust');
% 
% cordex_lon = reshape(cordex_lon,1,no_y*no_x);
% cordex_lat = reshape(cordex_lat,1,no_y*no_x);
% plot_data_smooth=reshape(plot_data_smooth,1,no_y*no_x);
% plot_data=reshape(plot_data,1,no_y*no_x);
% title(map_text)
% CORDEX_pcolor_plot(cordex_lat,cordex_lon,plot_data_smooth,proj,nw_corner,se_corner,color_interval,color_scheme,contour_type,add_zeroline,add_clines,mask,map_text,plot_unit,colorbar_location,prnt,output_name,language,seas,nanmean(plot_data))

%% Write some values into text files for the box plots
output_name = [deblank(cordex_var) '_' deblank(future_scenario) '_' num2str(future_start_year) '_to_' num2str(future_end_year)];
mn=nanmean(mean_anom_cordex_ENS);
md=nanmean(med_anom_cordex_ENS);
mi=nanmean(min_anom_cordex_ENS);
ma=nanmean(max_anom_cordex_ENS);
tp=nanmean(anom_cordex_ENS_10);
np=nanmean(anom_cordex_ENS_90);
if (FirstTime)
   fid = fopen([output_name '.txt'],'w');
   fprintf(fid,'%5s %7s %7s %7s %7s %7s %7s\n','Period', 'Mean','Median','Min', 'Max', '10%', '90%');
else
   fid = fopen([output_name '.txt'],'a');
end   
fprintf(fid,'%5s %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f\n', seas, mn, md, mi, ma, tp, np  );
fclose(fid);


