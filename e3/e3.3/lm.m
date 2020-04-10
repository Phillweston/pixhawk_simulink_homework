function p = lm(func,p,x,y_dat,dp,p_min,p_max)
%���룺
%func  ������ y_hat = func(x,p)
%p: �����Ʋ����ĳ�ʼ��ֵ
%x: ԭʼֵ
%y_dat:
%dp:��Jocobian���������йء����ƺ�����ʱ���Ա������Ŷ�delta
%    �㷨��ʹ��:del=dp*abs(p),Ĭ��Ϊ0.001.
%p_min�������Ʋ�������Сֵ��Ĭ��-10*abs(p)
%p_max:�����Ʋ��������ֵ��Ĭ�� 10*abs(p)

%���
%p:���ƵĲ���

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
 if nargin < 5, dp = 0.001; end
 if nargin < 6, p_min   = -100*abs(p); end
 if nargin < 7, p_max   =  100*abs(p); end

 p_min=p_min(:); p_max=p_max(:); 	% make column vectors

 if length(dp) == 1
     dp = dp*ones(Npar,1);
 end
 
 stop = 0;				        % termination flag

 [alpha,beta,delta_y] = lm_matx(func,x,p,y_dat,dp);
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
    
        [alpha,beta,delta_y] = lm_matx(func,x,p,y_dat,dp);
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
        
function dydp = lm_dydp(func,x,p,y,dp)

% dydp = lm_dydp(func,x,p,y,{dp})
%
% ����func��p��һ�׵�������Jocobian����
% -------- INPUT VARIABLES ---------
% func : y_hat = func(x,p)
% x :mά����
% p :nά����
% y  = func(t,p) n-vector initialised by user before each call to lm_dydp
% dp = ����ʱ���Ŷ���С
%      dp(j)>0 f'(x)=(f(x,p+dp*p)-f(x,p-dp*p))/(2*dp*p)
%      dp(j)<0 f'(x)=(f(x,p+dp*p)-f(x,p))/(dp*p)
%      Default:  0.001;
%---------- OUTPUT VARIABLES -------
% dydp = Jacobian Matrix dydp(i,j)=dy(i)/dp(j)	i=1:n; j=1:m 

 m=length(y);			% number of data points
 n=length(p);			% number of parameters

 if nargin < 5
	dp = 0.001*ones(1,n);
 end

 ps=p; dydp=zeros(m,n); del=zeros(n,1); % initialize Jacobian to Zero

 for j=1:n                              % loop over all parameters

     del(j) = dp(j) * p(j);  % parameter perturbation
     p(j)   = ps(j) + del(j);	      % perturb parameter p(j)

     if del(j) ~= 0
        y1=feval(func,x,p);
      
       if (dp(j) < 0)
            dydp(:,j) = (y1-y)./del(j);
       else
            p(j) = ps(j) - del(j);
	        dydp(:,j) = (y1-feval(func,x,p)) ./ (2 .* del(j));
         
       end
    end

     p(j)=ps(j);		% restore p(j)
 end

% endfunction # ------------------------------------------------------ LM_DYDP



function [alpha,beta,delta_y] = lm_matx(func,x,p,y_dat,dp)
% [alpha,beta,Chi_sq,y_hat,dydp] = lm_matx(func,t,p,y_dat,weight_sq,{da},{c})
%
% Evaluate the linearized fitting matrix, alpha, and vector beta, 
% Used by Levenberg-Marquard algorithm, lm.m   
% -------- INPUT VARIABLES ---------
% func  = function ofpn independent variables, p, and m parameters, p,
%         returning the simulated model: y_hat = func(x,p)
% x     = m-vectors or matrix of independent variables (used as arg to func)
% p     = n-vector of current parameter values
% y_dat = n-vector of data to be fit by func(t,p,c)  
% dp = fractional increment of 'p' for numerical derivatives
%      dp(j)>0 central differences calculated
%      dp(j)<0 one sided differences calculated
%      dp(j)=0 sets corresponding partials to zero; i.e. holds p(j) fixed
%      Default:  0.001;
%---------- OUTPUT VARIABLES -------
% alpha:J'J
% beta:J'delta_y
% delta_y:

 Npar = length(p);		% number of parameters 

 if nargin < 5
      dp = 0.001;
 end
 
 alpha = zeros(Npar);
 beta  = zeros(Npar,1);
  
 y_hat = feval(func,x,p);	% evaluate model using parameters 'p'

 delta_y = y_dat - y_hat';	% residual error between model and data

dydp = lm_dydp(func,x,p,y_hat,dp);

 alpha = dydp'*  dydp;%J'J  
 beta  = dydp'* delta_y; %J'delta_y
 
% endfunction  # ------------------------------------------------------ LM_MATX

