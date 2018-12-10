% boxplot for Norway only DJF, MAM, JJA, SON, År
% In KiN2100 Figure 5.2.4

close all;clear;
regions=['Norway        ';...
         'Varanger      ';...
         'Nordland-Troms';...
         'Finnmarksvidda';...
         'Trøndelag     ';...
         'Vestlandet    ';... 
         'Østlandet     '];
    
cordex_var='tas';
hist_scenario='historical'; 
hist_start_year='1971';
hist_end_year='2000';
future_start_year='2071';
future_end_year='2100'; 

input_dir='/Home/siv5/sma087/Steffi/UNI_Klima/KSS/KiN2100/DATA/EUR-11/NORWAY/';

file_extention='empirisk';

% read in regional data for rcp2.6, rcp 4.5 and rcp8.5 
ascii_file_26=[input_dir upper(cordex_var) '_' file_extention '_RCP26_' num2str(future_start_year) '_' num2str(future_end_year) '.txt'];
[mod_data_region,mod_data_season,mod_data_mean_26,mod_data_median_26,mod_data_10prctl_26,mod_data_90prctl_26]=textread(ascii_file_26,'%s%s%7.2f%7.2f%7.2f%7.2f\n','headerlines',24);

ascii_file_45=[input_dir upper(cordex_var) '_' file_extention '_RCP45_' num2str(future_start_year) '_' num2str(future_end_year) '.txt'];
[mod_data_region,mod_data_season,mod_data_mean_45,mod_data_median_45,mod_data_10prctl_45,mod_data_90prctl_45]=textread(ascii_file_45,'%s%s%7.2f%7.2f%7.2f%7.2f\n','headerlines',24);

ascii_file_85=[input_dir upper(cordex_var) '_' file_extention '_RCP85_' num2str(future_start_year) '_' num2str(future_end_year) '.txt'];
[mod_data_region,mod_data_season,mod_data_mean_85,mod_data_median_85,mod_data_10prctl_85,mod_data_90prctl_85]=textread(ascii_file_85,'%s%s%7.2f%7.2f%7.2f%7.2f\n','headerlines',24);

RCP26M=reshape(mod_data_median_26,5,7);
RCP26L=reshape(mod_data_10prctl_26,5,7);
RCP26H=reshape(mod_data_90prctl_26,5,7);

RCP45M=reshape(mod_data_median_45,5,7);
RCP45L=reshape(mod_data_10prctl_45,5,7);
RCP45H=reshape(mod_data_90prctl_45,5,7);

RCP85M=reshape(mod_data_median_85,5,7);
RCP85L=reshape(mod_data_10prctl_85,5,7);
RCP85H=reshape(mod_data_90prctl_85,5,7);

RCP26L=[RCP26L(2,:);RCP26L(3,:);RCP26L(4,:);RCP26L(5,:);RCP26L(1,:)];
RCP26M=[RCP26M(2,:);RCP26M(3,:);RCP26M(4,:);RCP26M(5,:);RCP26M(1,:)];
RCP26H=[RCP26H(2,:);RCP26H(3,:);RCP26H(4,:);RCP26H(5,:);RCP26H(1,:)];

RCP45L=[RCP45L(2,:);RCP45L(3,:);RCP45L(4,:);RCP45L(5,:);RCP45L(1,:)];
RCP45M=[RCP45M(2,:);RCP45M(3,:);RCP45M(4,:);RCP45M(5,:);RCP45M(1,:)];
RCP45H=[RCP45H(2,:);RCP45H(3,:);RCP45H(4,:);RCP45H(5,:);RCP45H(1,:)];

RCP85L=[RCP85L(2,:);RCP85L(3,:);RCP85L(4,:);RCP85L(5,:);RCP85L(1,:)];
RCP85M=[RCP85M(2,:);RCP85M(3,:);RCP85M(4,:);RCP85M(5,:);RCP85M(1,:)];
RCP85H=[RCP85H(2,:);RCP85H(3,:);RCP85H(4,:);RCP85H(5,:);RCP85H(1,:)];

% group boxes
pos1=0.4:1:4.4;
pos2=0.6:1:4.6;
% define colors
rcp_cols=[0.6 0.6 1;1 0.4 0.4; 1 .7 0];

for j=1;%:7
 figure(j);
 grid off;hold on;box on;

  %% 10 to 90th percentile boxes
  for s=1:5
    h1=patch([pos1(s)-0.25 pos2(s)-0.25 pos2(s)-0.25 pos1(s)-0.25],[RCP26L(s,j) RCP26L(s,j) RCP26H(s,j) RCP26H(s,j)],'g');
    set(h1,'EdgeColor','k','FaceColor',rcp_cols(3,:));
    plot([pos1(s)-0.25-.05 pos2(s)-0.25+.05],[RCP26M(s,j) RCP26M(s,j)],'k','LineWidth',3);  
      
    h2=patch([pos1(s) pos2(s) pos2(s) pos1(s)],[RCP45L(s,j) RCP45L(s,j) RCP45H(s,j) RCP45H(s,j)],'g');
    set(h2,'EdgeColor','k','FaceColor',rcp_cols(1,:));
    plot([pos1(s)-.05 pos2(s)+.05],[RCP45M(s,j) RCP45M(s,j)],'k','LineWidth',3);
    
    h3=patch([pos1(s)+0.25 pos2(s)+0.25 pos2(s)+0.25 pos1(s)+0.25],[RCP85L(s,j) RCP85L(s,j) RCP85H(s,j) RCP85H(s,j)],'g');
    set(h3,'EdgeColor','k','FaceColor',rcp_cols(2,:));
    plot([pos1(s)+0.25-.05 pos2(s)+0.25+.05],[RCP85M(s,j) RCP85M(s,j)],'k','LineWidth',3);
  end 
  set(gca,'XTick',0.5:1:4.5,'FontSize',12);
  set(gca,'XTickLabel',{'DJF','MAM','JJA','SON','Year'},'FontSize',12);
  ylim([0 11]); xlim([0 5]);

  hleg = legend([h1,h2,h3], 'RCP2.6','RCP4.5', 'RCP8.5',2);
%   set(hleg,'YColor',[1 1 1],'XColor',[1 1 1]);
%   title({'Change in tas (\circC) from 1971-2000 to 2071-2100';'Empirical statistical downscaling'},'FontSize',14);
  ylabel('\circC','FontSize',14);
%   text(3,8,regions(j,:),'FontSize',12);

%   cd fig/
%   printfile=[num2str(j) '_Empirisk_' cordex_var '_RCP26_RCP45_RCP85_seasons_' regions(j,:) '_2031-2060.png'];
%   print ('-dpng',printfile)
% 
%   printfile=[num2str(j) '_Empirisk_' cordex_var '_RCP26_RCP45_RCP85_seasons_' regions(j,:) '_2031-2060.eps'];
%   print ('-depsc',printfile)
%   cd ..
cd fig/
  printfile=[num2str(j) '_Empirisk_' cordex_var '_RCP26_RCP45_RCP85_seasons_' regions(j,:) '_2071-2100_eng.png'];
  print ('-dpng',printfile)

  printfile=[num2str(j) '_Empirisk_' cordex_var '_RCP26_RCP45_RCP85_seasons_' regions(j,:) '_2071-2100_eng.eps'];
  print ('-depsc',printfile)
  
  printfile=[num2str(j) '_Empirisk_' cordex_var '_RCP26_RCP45_RCP85_seasons_' regions(j,:) '_2071-2100_eng.tiff'];
  print ('-dtiff',printfile)
  cd ..
end


