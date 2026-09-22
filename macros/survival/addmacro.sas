*downloaded from here: https://stats.oarc.ucla.edu/sas/examples/sakm/survival-analysis-by-john-p-klein-and-melvin-l-moeschbergerchapter-10-additive-hazards-regression-model/;

%macro additive(dataset,siglevel,timeunit,effects,option,contrast,outdat1,
outdat2);

* dataset: data set that contains time, censor indicator, covariates;
* siglevel: significance level;
* timeunit: unit of time;
* effects: the covariates;
* option: character vector defining which options are chosen;
* contrast: contrast vector (or matrix);
* outdat1: first output data set;
* outdat2: second output data set;

	use &dataset;
	read all var _num_ into imldat;
	goodrow=LOC(((imldat=.)  [,+])=0);   * searches for missing values;
	missing=LOC(((imldat=.)  [,+])^=0); * identifies rows w/missing values;
	imldat=imldat[goodrow,];	     * deletes rows with missing values;
	
	n=nrow(imldat);     * number of rows in Y;
	col=ncol(imldat);
	pprime=col-1;       * number of columns in Y (baseline + covariates);
	p=pprime-1;         * number of covariates;
	t=imldat[,1];       * death or censored time;
	c=imldat[,2];       * 1=uncensored, 0=censored;
	zero=j(n,1,0);
	A=j(n,1,0);         * n-vector whose ith element is 1 if subject i
				experiences event;
	B=j(pprime,1,0);    * estimates for Betas;
	s=j(pprime,1,0);    * decoy for Betas;
	betatime=j(n,pprime,0);   * Betas over time;
	cov=j(pprime,pprime,0);   * covariance for Betas;
	cm=j(pprime,pprime,0);    * decoy for covariance;
	var=j(pprime,1,0);        * variance of Betas;
	stdev=j(pprime,1,0);      * stdev of Betas;
	LCI=j(pprime,1,0);        * lower confidence bound for each estimate;
	UCI=j(pprime,1,0);        * upper confidence bound for each estimate;
	sdtime=j(n,pprime,0);	  * stdev of Betas over time;
	Lcontime=j(n,pprime,0);   * lower conf bound over time for each est;
	Ucontime=j(n,pprime,0);   * upper conf bound over time for each est;
	GLTEST=I(p);
	constant=j(p,1,0);
	GLTEST=constant || GLTEST;
	K=j(p,p,0);         * weight for U;
	U=j(p,1,0);         * test stat based on this vector;
	V=j(p,p,0); 	    * variance matrix for U;
	xy=j(n,2,0);
	
	
*Check to see if data is sorted in ascending order;
	do i=2 to n;
	 if t[i-1]>t[i] then do;
	  print 'Data not sorted by time in ascending order!';
	  abort;
	 end;
	end;

* Option [2,1] is for testing contrasts;	  
	if &option[2,1]={y} then do;
	 rowcon=nrow(&contrast);
	 conK=j(rowcon,rowcon,0);
	 conU=j(rowcon,1,0);
	 conV=j(rowcon,rowcon,0);
	end;
	
* Macro that checks if Y is singular;
	%macro rankmat(time,estimtes);
	rank=round(trace(ginv(Y)*Y));
	if rank^=min(n,pprime) then do;
	 fintime=&time;             * final time for estimates;
	 stop;
	end;
	%mend;    

* Macro that creates confidence intervals for untied observations;
   	%macro confint(est,covarian,alpha);
   	%global stdev sdtime LCI UCI Lcontime Ucontime;
   	zscore=probit(1-&alpha/2);
	do f=1 to pprime;
	 stdev[f,]=sqrt(&covarian[f,f]);
	 sdtime[i,f]=sqrt(&covarian[f,f]);   * stdev for betas thru time;
	 LCI[f,]=&est[f,]-(zscore#stdev[f,]);
	 UCI[f,]=&est[f,]+(zscore#stdev[f,]);   
	 Lcontime[i,f]=LCI[f,1];
	 Ucontime[i,f]=UCI[f,1];
	end;
	%mend;   

* Macro that creates confidence intervals for tied observations;
	%macro conftied(est,covarian,alpha);
	%global stdev sdtime LCI UCI Lcontime Ucontime;
	zscore=probit(1-&alpha/2);
	do ff=i to jj;
	 do f=1 to pprime;
	  stdev[f,]=sqrt(cov[f,f]);
	  sdtime[ff,f]=sqrt(&covarian[f,f]);
	  LCI[f,]=&est[f,]-(zscore#stdev[f,]);
	  UCI[f,]=&est[f,]+(zscore#stdev[f,]);   
	  Lcontime[ff,f]=LCI[f,1];
	  Ucontime[ff,f]=UCI[f,1];
	 end;
	end;  
	%mend;
		
* Creating Y matrix; 
	Y=j(n,pprime,0);
	Y[,1]=1;            * baseline column is 1s;
	do q= 2 to pprime;
	 Y[,q]=imldat[,q+1];
	end;
* Computing the estimates:;
	do i=1 to (n-1);

	 if t[i]=t[1] then do;  
	  s[,1]=0;cm[,1]=0;
	 end; 
	 else do;
	  s[,1]=B[,1];cm=cov;
	 end;

* If time(i) is not equal to time(i+1):;	 
	  if t[i]^=t[i+1] then do;
	   if c[i]=0 then do;            * for censored observation;
	   B=s;
	    do f=1 to pprime;
	     betatime[i,f]=B[f,1];
            end;
	   cov=cm;
	   K=K;
	   U=U;
	   V=V;
	   if &option[2,1]={y} then do;
	    conK=conK;
	    conU=conU;
	    conV=conV;
	   end; 
	   %confint(B,cov,&siglevel);
	   Y[i,]=0;
	   %rankmat((t[i]),B);
	   end;

	   if c[i]>0 then do;             * for uncensored observation;
	   A[i]=1;
	   X=inv(Y`*Y)*Y`;
	   B=s+(X*A);
	    do f=1 to pprime;
	     betatime[i,f]=B[f,1];
            end;
	   cov=cm+(X*(diag(A))*X`);
	   K=inv(diag(GLTEST*inv(Y`*Y)*GLTEST`));
	   U=U+(K*GLTEST*X*A);
	   V=V+(K*GLTEST*X*diag(A)*X`*GLTEST`*K`);
	   if &option[2,1]={y} then do;
	    conK=inv(diag(&contrast*inv(Y`*Y)*&contrast`));
	    conU=conU+(conK*&contrast*X*A);
	    conV=conV+(conK*&contrast*X*diag(A)*X`*&contrast`*conK`);
	   end; 
	   %confint(B,cov,&siglevel);
	   Y[i,]=0;
	   A[i]=0;
	   %rankmat((t[i]),B);
	   end;

   	  end;

* If time(i) is equal to time(i+1):;	
	  if t[i]=t[i+1] then do;
	   d=c[i]+c[i+1];
	   do j=i+2 to n;
	    if t[i]=t[j] then do;
	     d=d+c[j];	* d is the # of uncensored cases at time(i);
	    end;
	    else if t[i]^=t[j] then do;
	     jj=j-1;	* jj is the last case number that is tied at time(i);
	     j=n;  
	    end;
	   end;
	   if d=0 then do;		* for the censored tied times; 
	    B=s;
	    do ff=i to jj;
	     do f=1 to pprime;
	      betatime[ff,f]=B[f,1];
             end;
            end;
	    cov=cm;
	    K=K;
	    U=U;
	    V=V;
	    if &option[2,1]={y} then do;
	     conK=conK;
	     conU=conU;
	     conV=conV;
	    end;
	    %conftied(B,cov,&siglevel);
	    do m=i to jj;
	     Y[m,]=0;
	    end;
	    i=jj;
	    %rankmat((t[i]),B);
	   end;
	   if d>0 then do;		* for the uncensored tied times;
	    do dd=i to jj;
	      if c[dd]=1 then A[dd]=1;
	    end; 
	    X=inv(Y`*Y)*Y`;
	    B=s+(X*A);
	    do ff=i to jj;
	     do f=1 to pprime;
	      betatime[ff,f]=B[f,1];
             end;
            end;
	    cov=cm+(X*(diag(A))*X`);
	    K=inv(diag(GLTEST*inv(Y`*Y)*GLTEST`));
	    U=U+(K*GLTEST*X*A);
	    V=V+(K*GLTEST*X*diag(A)*X`*GLTEST`*K`);
	    if &option[2,1]={y} then do;
	     conK=inv(diag(&contrast*inv(Y`*Y)*&contrast`));
	     conU=conU+(conK*&contrast*X*A);
	     conV=conV+(conK*&contrast*X*diag(A)*X`*&contrast`*conK`);
	    end;
	    %conftied(B,cov,&siglevel);
	    do m=i to jj;
	     Y[m,]=0;
	     A[m]=0;
	    end;
	    i=jj;
	    %rankmat((t[i]),B);
	   end;
	  end;

	end;
	
	fincase=i;  * final case number, where estimates are still estimable;
	restime=t[1:fincase,];       * restricted time interval for estimates;
	Lcontime=Lcontime[1:fincase,];
	Ucontime=Ucontime[1:fincase,];
	betatime=betatime[1:fincase,];
	sdtime=sdtime[1:fincase,];	

* Create BStime which contains parameter estimates & standard deviations 
over time;
	BStime=j(fincase,2*pprime+1,0);
	BStime[,1]=restime;          * first column is time;
	BStime[,2]=betatime[,1];     * second column is BO estimate;
	BStime[,3]=sdtime[,1];       * third column is standard deviation(BO);
	do i=2 to pprime;
	 BStime[,i*2]=Betatime[,i];  * even columns are B estimates;
	 BStime[,i*2+1]=sdtime[,i];  * odd columns are st.dev;
	end; 
	BStime=BStime[1:fincase,];   * eliminates final rows where estimate is
	                               not estimable (YprimeY not full rank);

* GLOBAL TEST;
	gltstat=U`*inv(V)*U;
	zstat=sqrt(gltstat);
	dfgltest=p;
	pval=1-probchi(gltstat,dfgltest);
	col1={"Chi-Square"};
	col2={"d.f"};
	col3={"p-value"};
	timecol={"Time"};
	lab={" "};
	blankcol={" "};
	mattrib restime colname=timecol label=lab;
	mattrib fintime colname=blankcol label=lab format=4.2;
	mattrib gltstat colname=col1 label=lab format=10.4;
	mattrib dfgltest colname=col2 label=lab format=3.;
	mattrib pval colname=col3 label=lab format=6.4;
	
* INDIVIDUAL effects;
	indchi=j(p,1,0);
	indpval=j(p,1,0);
	do i=1 to p;
	 indchi[i]=U[i]##2/V[i,i];
	 indpval[i]=1-probchi(indchi[i],1);
	end;
	inddf=j(p,1,1);
	col4={"Effect"};
	mattrib indchi colname=col1 label=lab format=10.4;
	mattrib inddf colname=col2 label=lab format=3.;
	mattrib indpval colname=col3 label=lab format=6.4;
	mattrib &effects colname=col4 label=lab;
	
	
* contrasts;
	if &option[2,1]={y} then do;
	 statcon=conU`*inv(conV)*conU;
	 dfcon=rowcon;
	 pvalcon=1-probchi(statcon,dfcon);
	 mattrib statcon colname=col1 label=lab format=10.4;
	 mattrib dfcon colname=col2 label=lab format=3.;
	 mattrib pvalcon colname=col3 label=lab format=6.4;
	 row1={"Contrast Matrix"};
	 mattrib &contrast rowname=row1 label=lab;
	end;
	
	
	print '          Additive Hazards Model          ',,,;
	mattrib n colname=lab label=lab;
	misnames={"Case #"};	
	mattrib missing colname=misnames label=lab;
	if nrow(missing)>0 then do;
	 missing=t(missing);
	 print 'The following observations have missing values and are excluded 
from analysis:', missing,;
	 print n 'observations used in analysis.';
	end;
	else do;
	 print 'No missing data: all observations were used in analysis.';
	 print n 'observations used.';
	end; 
	print 'Estimates are restricted to the time interval 0 to' fintime,;
	print '               Global Test                ';
	print  gltstat dfgltest pval;
	print "   ", "  ", "   ";
	print '           Analysis of Variance           ';
	print &effects indchi inddf indpval;
	print "   ", "  ", "   ";
	
	
* Printing contrast output;
	if &option[2,1]={y} then do;
	 print '        Test of Linear Combinations     ';
	 print &contrast;
	 print statcon dfcon pvalcon;
	end;
	
* Printing beta estimate, standard deviation at each time;
	if &option[1,1]={y} then do;
	 endcount=2*pprime;
	 c1={"Beta"};
	 c2={"Standard Deviation"};
	 mattrib parname colname=blankcol label=lab;
	 mattrib betaspr colname=c1 label=lab format=10.4;
	 mattrib stdevspr colname=c2 label=lab format=10.4;
	 j=0;
	 temp=t(&effects);
	 tempnew='Baseline' || temp;
	 do i=2 to endcount by 2;
	  betaspr=BStime[,i];
	  stdevspr=BStime[,i+1];
	  j=j+1;
	  parname=tempnew[,j];
	  print 'Cumulative estimate and standard deviation for:' parname;
	  print restime betaspr stdevspr;
	 end;
	end;
	
	
* Line Plots;
	if &option[4,1]={y} then do;
	 xy=j(fincase,2,0);
	 xy[,1]=restime;
	 temp=t(&effects);
	 names='Baseline' || temp;
	 do gg=1 to pprime;
	  xy[,2]=betatime[,gg];
	  call pgraf(xy,'*',&timeunit,names[,gg]);
	 end; 
	end;
	
	
* Creating first output dataset;
	if &option[3,1]={y} then do;	
	NEW1= restime || betatime || sdtime || Lcontime || Ucontime;
        create &outdat1 from NEW1; 
	 append from NEW1;
	end;
	
* Creating second output dataset;
	if &option[5,1]={y} then do;
	 NEW2=U || V;
	 create &outdat2 from NEW2;
	 append from NEW2;
	end;
	
%mend;
