 clear;
 [datapoints, numpoints] = px4_read_binary_file('e4_A.bin');
ax=datapoints(1,:);%��λ��m/s2
ay=datapoints(2,:);
az=datapoints(3,:);
gx=datapoints(4,:);%��λ��rad/s
gy=datapoints(5,:);
gz=datapoints(6,:);
phi_px4=datapoints(7,:);%PX4�н���ĺ���ǣ���λ��rad
theta_px4=datapoints(8,:);%PX4�н���ĺ���ǣ���λ��rad
timestamp=datapoints(9,:);%ʱ�������λ��us

n=length(ax);%�ɼ����ݸ���
Ts=zeros(1,n);%ʱ����
Ts(1)=0.004;

for k=1:n-1
    Ts(k+1)=(timestamp(k+1)-timestamp(k))*0.000001;
end

theta_am=zeros(1,n);%���ٶȼ����theta��
phi_am=zeros(1,n);%���ٶȼ����phi��
theta_gm=zeros(1,n);%�����ǻ��ֵ�theta��
phi_gm=zeros(1,n);%�����ǻ��ֵ�phi��
theta_cf=zeros(1,n);%�����˲��õ���theta��
phi_cf=zeros(1,n);%�����˲��õ���phi��
tao = 0.1;
for k=2:n
    %ʹ�ü��ٶȼ����ݼ���ŷ����
    g=sqrt(ax(k)*ax(k)+ay(k)*ay(k)+az(k)*az(k));
    theta_am(k)=asin(ax(k)/g);%��ʽ��9.2��
    phi_am(k)=-asin(ay(k)/(g*cos(theta_am(k))));
    %ʹ�����������ݼ���ŷ����
    theta_gm(k)=theta_gm(k-1)+gy(k)*Ts(k);
    phi_gm(k)=phi_gm(k-1)+gx(k)*Ts(k);
    %�����˲�
    theta_cf(k)=tao/(tao+Ts(k))*(theta_cf(k-1)+gy(k)*Ts(k))+Ts(k)/(tao+Ts(k))*theta_am(k);%��ʽ��9.15��
    phi_cf(k)=tao/(tao+Ts(k))*(phi_cf(k-1)+gx(k)*Ts(k))+Ts(k)/(tao+Ts(k))*phi_am(k);%��ʽ��9.17��
end

t=timestamp*0.000001;
rad2deg=180/pi;%����ת���ɽǶ�ϵ��
figure(1)
subplot(2,1,1)
plot(t,theta_gm*rad2deg,'g',t,theta_am*rad2deg,'b',t,theta_cf*rad2deg,'r')
legend('gyro','acc','cf');
ylabel('theta(deg)')
title('������')
subplot(2,1,2)
plot(t,theta_cf*rad2deg,'r',t,theta_px4*rad2deg,'k')
legend('cf','px4');
xlabel('t(s)')
ylabel('theta(deg)')


figure(2)
subplot(2,1,1)
plot(t,phi_gm*rad2deg,'g',t,phi_am*rad2deg,'b',t,phi_cf*rad2deg,'r')
legend('gyro','acc','cf');
ylabel('theta(deg)')
title('�����')
subplot(2,1,2)
plot(t,phi_cf*rad2deg,'r',t,phi_px4*rad2deg,'k')
legend('cf','px4');
xlabel('t(s)')
ylabel('theta(deg)')
