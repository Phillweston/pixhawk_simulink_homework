function [ phi_cf,theta_cf ] =Attitude_cf(dt,z,phi_cf_k,theta_cf_k,tao)
%Attitude_cf �����˲�������̬��
%���룺
%   dt:ʱ����,��λ��s
%   z:����ֵ[gx,gy,gz,ax,ay,az],��λ��rad/s,m/s2
%   phi_cf_k,theta_cf_k:��һʱ�̵ĽǶ�ֵ����λ��rad
%   tao:�˲�ϵ��
%�����
%   phi_cf,theta_cf:��̬�ǣ���λ��rad

    gx=z(1);gy=z(2);
    ax=z(4);ay=z(5);az=z(6);
    
    g=sqrt(ax*ax+ay*ay+az*az);
    theta_am=asin(ax/g);%��ʽ��9.2��
    phi_am=-asin(ay/(g*cos(theta_am)));
    
    theta_cf=tao/(tao+dt)*(theta_cf_k+gy*dt)+dt/(tao+dt)*theta_am;%��ʽ��9.15��
    phi_cf=tao/(tao+dt)*(phi_cf_k+gx*dt)+dt/(tao+dt)*phi_am;%��ʽ��9.17��
end

