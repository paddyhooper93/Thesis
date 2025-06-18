i={'3T_Neutral', '3T_Rot1', '3T_Rot2'};
Xsim_matr=zeros(6,3);
Hfen_matr=zeros(6,3);
Rmse_matr=zeros(6,3);
x=0;
for dataset=i
    load([dataset{1}, '_5_Vars.mat'], 'Xsim', 'Hfen', 'Rmse');
    x=x+1;
    Xsim_matr(:,x)=Xsim;
    Hfen_matr(:,x)=Hfen;
    Rmse_matr(:,x)=Rmse;
end
Xsim_mean=mean(Xsim_matr,2);
Hfen_mean=mean(Hfen_matr,2);
Rmse_mean=mean(Rmse_matr,2);
save('3T_Mean', 'Xsim_mean', 'Hfen_mean', 'Rmse_mean');

Xsim_matr=zeros(6,3);
Hfen_matr=zeros(6,3);
Rmse_matr=zeros(6,3);
y=0;
j={'7T_Neutral', '7T_Rot1', '7T_Rot2', '7T_Rot3'};

for dataset=j
    load([dataset{1}, '_4_Vars.mat'], 'Xsim', 'Hfen', 'Rmse');
    y=y+1;
    Xsim_matr(:,y)=Xsim;
    Hfen_matr(:,y)=Hfen;
    Rmse_matr(:,y)=Rmse;    
end
Xsim_mean=mean(Xsim_matr,2);
Hfen_mean=mean(Hfen_matr,2);
Rmse_mean=mean(Rmse_matr,2);
save('7T_Mean', 'Xsim_mean', 'Hfen_mean', 'Rmse_mean');
