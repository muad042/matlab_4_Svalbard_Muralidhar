function [map_text] = CORDEX_make_latlon_maptext(unique_models,unique_model_runs_indx,model_runs,fut_institutes,future_RCMs,no_simulations,cordex_var,plot_unit,future_scenario,season,hist_start_year,hist_end_year,future_start_year,future_end_year,add_zeroline,add_clines)
% PURPOSE
% making map text for lat lon plots

no_unique_models=size(unique_models,1);


 % map text
 map_text1=['Number of simulations: ' num2str(no_simulations) ];%' Number of models: ' num2str(no_unique_models)]; 
 map_text2=['']; 
 map_text3=['Models used: ']; 
 map_text4=['']; 
 no_models_pr_line=7;
 no_txtmodels=min([no_models_pr_line,size(unique_models,1)]);
 for j=1:no_txtmodels
     if j==1
         map_text4=['simulation: ' map_text4  deblank(unique_models(j,:)) ' (' deblank(model_runs) ') /' num2str(future_RCMs)];
%          map_text4=[map_text4  deblank(fut_institutes) ': ' deblank(unique_models(j,:)) ' (' num2str(sum(~isnan(unique_model_runs_indx(j,:)))) ')/' num2str(future_RCMs)];
     else
         map_text4=['simulation: ' map_text4 ', ' deblank(fut_institutes) '-' deblank(unique_models(j,:)) ' (' num2str(sum(~isnan(unique_model_runs_indx(j,:)))) ')/' num2str(future_RCMs)];
     end
 end
%  map_text5=['']; 
%  no_txtmodels=min([2*no_models_pr_line,size(unique_models,1)]);
%  for j=no_models_pr_line+1:no_txtmodels
%      if j==no_models_pr_line+1
%          map_text5=[map_text5  deblank(unique_models(j,:)) ' (' num2str(sum(~isnan(unique_model_runs_indx(j,:)))) ')'];
%      else
%          map_text5=[map_text5 ', ' deblank(unique_models(j,:)) ' (' num2str(sum(~isnan(unique_model_runs_indx(j,:)))) ')'];
%      end
%  end
%  map_text6=['']; 
%  no_txtmodels=min([3*no_models_pr_line,size(unique_models,1)]);
%  for j=2*no_models_pr_line+1:no_txtmodels
%      if j==2*no_models_pr_line+1
%          map_text6=[map_text6  deblank(fut_institutes) '-' deblank(future_GCMs(j,:)) '-' deblank(future_RCMs(j,:)) '-' deblank(unique_models(j,:)) ' (' num2str(sum(~isnan(unique_model_runs_indx(j,:)))) ')'];
%      else
%          map_text6=[map_text6 ', ' deblank(fut_institutes) '-' deblank(future_GCMs(j,:)) '-' deblank(future_RCMs(j,:)) '-' deblank(unique_models(j,:)) ' (' num2str(sum(~isnan(unique_model_runs_indx(j,:)))) ')'];
%      end
%  end
 
 map_text7=['Variable: ' cordex_var '. Season (months avg. over): 1...12'];% num2str(season) ']' ];
 if strcmp(cordex_var,'pr')
   map_text8=['Data:  (SCEN-CNTRL)/CNTRL, SCEN: ' upper(future_scenario) '.'];
   map_text8a=['Time periods: CNTRL: ' num2str(hist_start_year) '-' num2str(hist_end_year) ', SCEN: ' num2str(future_start_year) '-' num2str(future_end_year)]; 
 else
   map_text8=['Data:  SCEN-CNTRL, SCEN: ' upper(future_scenario) '.'];
   map_text8a=['Time periods: CNTRL: ' num2str(hist_start_year) '-' num2str(hist_end_year) ', SCEN: ' num2str(future_start_year) '-' num2str(future_end_year)];   
 end
 map_text9=['Unit: ' plot_unit '; ' map_text1 ];%'  Black contour: [' num2str(add_zeroline) ']. White contours: [' num2str(add_clines) ']']; 
 map_text10=[''];
 
 
 map_text={map_text7;map_text8;map_text8a;map_text9;map_text4};
      

