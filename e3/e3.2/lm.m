function p = lm(func,p,x,y_dat,p_min,p_max)
%���룺
%func  ������ y_hat = func(x,p)
%p: �����Ʋ����ĳ�ʼ��ֵ
%x: ԭʼֵ
%y_dat:
%dp:��Jocobian���������йء����ƺ�����ʱ���Ա������Ŷ�delta
%    �㷨��ʹ��:del=dp*abs(p),Ĭ��Ϊ0.001.
%p_min�������Ʋ�������Сֵ��Ĭ��-100*abs(p)
%p_max:�����Ʋ��������ֵ��Ĭ�� 100*abs(p)

%���
%p:���ƵĲ���
%ע��
%����������calFunc��ģ��һ�µ�У�����⣬��Ȼ��Ҫ����lm_dydp_s����

 p = p(:); y_dat = y_dat(:);		%ת����������
 Npar = length(p); 			% �����Ʋ����ĸ���

 if length(x) ~= length(y_dat)
    disp('lm.m ����: x�ĳ��ȱ����y_dat�ĳ�����ȣ�');
 end

 %����
 MaxIter = 200000*Npar;	% ����������
 epsilon_1     = 1e-6;	% convergence tolerance for gradient
 epsilon_2     = 1e-6;	% convergence tolerance for parameters
 epsilon_4     = 1e-6;	% determines acceptance of a L-M step
 lambda_0      = 1e-5;	% initial value of damping paramter, lambda

 Fx_hst = [];
 %���û��ָ����������ôʹ��Ĭ�ϲ���
 if nargin < 5, p_min   = -100*abs(p); end
 if nargin < 6, p_max   =  100*abs(p); end

 p_min=p_min(:); p_max=p_max(:); 	% make column vectors
 stop = 0;				        % termination flag

 [alpha,beta,delta_y] = lm_matx(func,x,p,y_dat);
    Fx_old = delta_y' * delta_y;
    Fx_hst(1) =  Fx_old;
 if ( max(abs(beta)) < epsilon_1 )
	fprintf(' *** ��ʼ����ֵ�ӽ����ţ�Fx��������0 ***\n')
	fprintf(' *** epsilon_1 = %e\n', epsilon_1);
    fprintf('***Fx = %e\n',Fx_old);
	stop = 1;
 end
 
 %lambda��ʼֵ
	lambda  = lambda_0 * max(diag(alpha));	% Mathworks and Nielsen
	nu=2;
    
 iteration = 0;					% iteration counter
 while ( ~stop && iteration <= MaxIter )		% --- Main Loop

    iteration = iteration + 1;
    %�����仯�����ĸ��·�ʽ
    delta_p = ( alpha + lambda*diag(diag(alpha)) ) \ beta;	

    p_try = p + delta_p;                      % update the [idx] elements 
    p_try = min(max(p_min,p_try),p_max);           % apply constraints

    delta_y = y_dat - (feval(func,x,p_try))';       % residual error using a_try
    Fx = delta_y' * delta_y;
    Fx_hst(iteration+1) = Fx;
    rho = (Fx_old - Fx) / ( delta_p' * (lambda * delta_p + beta) ); % Nielsen

    if ( rho > epsilon_4 )		% ���Ƴ̶Ⱥã���Сlamda�������ӽ�Gauss-Newton���Ĳ���
        p = p_try(:);			% accept p_try
    
        [alpha,beta,delta_y] = lm_matx(func,x,p,y_dat);
        Fx = delta_y' * delta_y;
        Fx_old = Fx;
    
        lambda = lambda*max( 1/3, 1-(2*rho-1)^3 ); nu = 2;
    else	%���Ƴ̶Ȳʹ��С����
 	    lambda = lambda * nu;   nu = 2*nu;			% Nielsen
    end
    %�ж��Ƿ���Խ�������
   if ( max(abs(delta_p./p)) < epsilon_2  &&  iteration > 2 ) 
        fprintf(' **** ����������ڵ����������ȶ����� **** \n')
        fprintf(' **** epsilon_2 = %e\n', epsilon_2);
        fprintf('***��������Ϊ��%e\n',iteration);
        figure
        plot(1:iteration+1,Fx_hst(1:iteration+1))
        title('Fx����������ı仯')
        xlabel('��������')
        ylabel('Fx')
        stop = 1;
   end
   if ( max(abs(beta)) < epsilon_1  &&  iteration > 2 ) 
        fprintf(' **** Fxһ�׵�������0  **** \n')
        fprintf(' **** epsilon_1 = %e\n', epsilon_1);
        fprintf('***��������Ϊ��%e\n',iteration);
        figure
        plot(1:iteration+1,Fx_hst(1:iteration+1))
        title('Fx����������ı仯')
        xlabel('��������')
        ylabel('Fx')
        stop = 1;
   end
   if ( iteration == MaxIter )
	disp(' !! �ﵽ���������� %e����δ��ϳɹ� !!',MaxIter)
        stop = 1;
   end

 end					% --- End of Main Loop

 
function dydp = lm_dydp_s(x,p,y)
%������֪���ҵ�������ֱ�����������ֱ��ʹ�÷�������ó��ĵ���
   m=length(y);			% number of data points
   n=length(p);			% number of parameters
 dydp=zeros(m,n);
 for i=1:m
     dydp(i,1) = (x(1,i)+p(4))^2*p(1)/y(i); 
     dydp(i,2) = (x(2,i)+p(5))^2*p(2)/y(i);
     dydp(i,3) = (x(3,i)+p(6))^2*p(3)/y(i);
     dydp(i,4) = (x(1,i)+p(4))*p(1)^2/y(i);
     dydp(i,5) = (x(2,i)+p(5))*p(2)^2/y(i);
     dydp(i,6) = (x(3,i)+p(6))*p(3)^2/y(i);
 end
        


function [alpha,beta,delta_y] = lm_matx(func,x,p,y_dat)
% [alpha,beta,Chi_sq,y_hat,dydp] = lm_matx(func,t,p,y_dat)
%
% Evaluate the linearized fitting matrix, alpha, and vector beta, 
% Used by Levenberg-Marquard algorithm, lm.m   
% -------- INPUT VARIABLES ---------
% func  = function ofpn independent variables, p, and m parameters, p,
%         returning the simulated model: y_hat = func(x,p)
% x     = m-vectors or matrix of independent variables (used as arg to func)
% p     = n-vector of current parameter values
% y_dat = n-vector of data to be fit by func(x,p)  
%---------- OUTPUT VARIABLES -------
% alpha:J'J
% beta:J'delta_y
% delta_y:

 Npar = length(p);		% number of parameters 
 
 alpha = zeros(Npar);
 beta  = zeros(Npar,1);
  
 y_hat = feval(func,x,p);	% evaluate model using parameters 'p'

 delta_y = y_dat - y_hat';	% residual error between model and data

 dydp = lm_dydp_s(x,p,y_hat);

 alpha = dydp'*  dydp;%J'J  
 beta  = dydp'* delta_y; %J'delta_y
 
% endfunction  # ------------------------------------------------------ LM_MATX

