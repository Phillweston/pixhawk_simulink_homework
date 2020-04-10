clear;
%ģ�ͳ�ʼ����
ModelInit_RPM=557.1420;%�����ʼת�٣���λ��rad/s��

%�������
ModelParam_motorCr=1148*2;    %���ת��-��������б�ʣ���λ��rad/s��
ModelParam_motorWb=-141.4;    %���ת��-�������߳�����(��λ��rad/s��
ModelParam_motorT= 0.02;    %�������ʱ�䳣������λ��s��
ModelParam_motorJm = 0.0001287; %���������ת����������λ��kg.m^2��

%����������
%��������Ť��ϵ��Cm����λ��N.m/(rad/s)^2��
%���壺����M����λN.m����������ת��w����λ��rad/s����M=Cm*w^2
ModelParam_rotorCm=1.779e-07;
%����������ϵ��Ct����λ��N/(rad/s)^2��
%���壺����T����λ��N����T=Ct**w^2
ModelParam_rotorCt= 1.105e-05;

%����ϵ��Cd
%���壺����D��N),ǰ���ٶ�V��m/s����D=Cd*V^2
ModelParam_uavCd = 0.073 ;%����ϵ������λ�� N/(m/s)^2��
ModelParam_uavMass=1.4; %��������������λ��kg��
ModelParam_uavR=0.225; %��������ܰ뾶����λ��m��
ModelParam_uavJxx =0.0211;%x��ת����������λ�� kg.m^2��
ModelParam_uavJyy =0.0219;%y��ת����������λ�� kg.m^2��
ModelParam_uavJzz =0.0366;%z��ת����������λ�� kg.m^2��
ModelParam_uavJ= [ModelParam_uavJxx,0,0;0,ModelParam_uavJyy,0;0,0,ModelParam_uavJzz];

ModelParam_envGravityAcc=9.8;
