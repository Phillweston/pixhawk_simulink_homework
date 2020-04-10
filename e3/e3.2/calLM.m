close all
clc
clear

load AccRaw
g=1;
m=length(AccRaw);

y_dat = g*ones(m,1); %  
p0 = [1 1 1 0.0 0.0 0.0]';  
p_init = [1.0 1.0 1.0 0.1 0.1 0.1]';

y_raw = calFunc(AccRaw,p0);%δУ��ʱ�ļ��ٶ�ֵ
y_raw = y_raw(:);
r_raw = y_dat-y_raw;
p_fit = lm('calFunc',p_init,AccRaw,y_dat);
y_lm = calFunc(AccRaw,p_fit);%У����ļ��ٶ�ֵ
y_lm = y_lm(:);
r_lm = y_dat-y_lm;

kx = p_fit(1);
ky = p_fit(2);
kz = p_fit(3);
bx = p_fit(4);
by = p_fit(5);
bz = p_fit(6);

Ka1=[kx 0 0;0 ky 0;0 0 kz]
ba1=[bx by bz]'
save('calP1','Ka1','ba1')


figure
bar([r_raw'*r_raw,r_lm'*r_lm])
grid on;
set(gca,'XTickLabel',{'raw','lm'});
ylabel('ָ��');

t=1:m;
figure
title('���ٶȼ�У��')
plot(t,r_raw,t,r_lm)
legend('δУ��','��У��-LM')
xlabel('����ֵ������')
ylabel('�в�')
