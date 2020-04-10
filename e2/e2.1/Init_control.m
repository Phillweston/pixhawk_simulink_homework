clear

path('./icon/',path);
Init;

%constant parameters
RAD2DEG=57.2957795;
DEG2RAD=0.0174533;

%Initial condition
ModelInit_PosE=[0,0,-100];%��ʼλ��
ModelInit_VelB=[0,0,0];%��ʼ�ٶ�
ModelInit_AngEuler=[0,0,0]; %��ʼŷ����
ModelInit_RateB=[0,0,0]; %��ʼ���ٶ�
ModelInit_RPM=557.1420;%�����ʼת��

%Model Parameter
ModelParam_uavMass=1.4; %����������
ModelParam_uavR=0.225;%����뾶
ModelParam_uavJxx = 0.0211;%x����ת������
ModelParam_uavJyy = 0.0219;%y����ת������
ModelParam_uavJzz = 0.0366;%z����ת������
%ת����������
ModelParam_uavJ= [ModelParam_uavJxx,0,0;0,ModelParam_uavJyy,0;0,0,ModelParam_uavJzz];
ModelParam_uavDearo = 0;  %����������������ֱ����λ�ò� 

ModelParam_motorCr=1148;%�������-�ٶ�����б��
ModelParam_motorWb=-141.4;%�������-�ٶ��������
ModelParam_motorT= 0.02; %������Ի��ڳ���
ModelParam_motorJm =0.0001287;%���ת��+������ת������

ModelParam_rotorCm=1.779e-07;%������Ť��ϵ��
ModelParam_rotorCt=1.105e-05;%����������ϵ��

%��ͣ���ŵļ��㹫ʽ
%THR=(sqrt(ModelParam_uavMass*9.8/4/ModelParam_rotorCt)-ModelParam_motorWb)/ModelParam_motorCr;
