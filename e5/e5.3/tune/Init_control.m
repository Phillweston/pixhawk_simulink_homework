clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% e5.3/AttitudeControl_tune %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
path('.\icon\',path);
%ģ�Ͳ��� ����ģ�ͳ�ʼ���ļ�icon/init.m
Init;

%Initial condition
ModelInit_PosE=[0,0,-100];
ModelInit_VelB=[0,0,0];
ModelInit_AngEuler=[0,0,0];
ModelInit_RateB=[0,0,0];
ModelInit_RPM=557.1420;
ModelParam_envGravityAcc=9.8;
