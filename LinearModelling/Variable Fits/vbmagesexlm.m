%Running the VBM Age Model

Age = bbvars('Age');
Sex = bbvars('Sex');
nsubj = length(Age);

global stdsize
alphahat = nan(stdsize);
sexhat = nan(stdsize);
agehat = nan(stdsize);

agetdenom = nan(stdsize);
sextdenom = nan(stdsize);

sum_of_ys = imgload('vbm_smooth_mean_img').*nsubj;
agey = imgload('smooth_vbmagey');
sexy = imgload('smooth_vbmsexy');
agesexy = imgload('smooth_vbmagesexy');

XtX = [nsubj, sum(Age), sum(Sex); sum(Age), sum(Age.^2), sum(Sex.*Age); sum(Sex), sum(Sex.*Age), sum(Sex.^2) ];
XtXinv = inv(XtX);

vbm_mask = imgload('vbm_mask001');

%Note you don't have to store everything as X^TX is symmetric!
for I = 1:91
    disp(I)
    for J = 1:109
        for K = 1:91
            if vbm_mask(I,J,K)
                XtY = [sum_of_ys(I,J,K); agey(I,J,K); sexy(I,J,K)];
                
                coeffs = XtXinv*XtY; %#ok<MINV>
                
                alphahat(I,J,K) = coeffs(1);
                agehat(I,J,K) = coeffs(2);
                sexhat(I,J,K) = coeffs(3);
                
                agetdenom(I,J,K) = XtXinv(2,2);
                sextdenom(I,J,K) = XtXinv(3,3);
            end
        end
    end
end

imgsave(sexhat, 'smooth_vbm_agesexlm_sexcoeff')
imgsave(agehat, 'smooth_vbm_agesexlm_agecoeff')
imgsave(alphahat, 'smooth_vbm_agesexlm_intercept')


%% Generate sigma^2 image
fprintf('Sigma^2 calculation\n')
subs4mean = loaddata('subs4mean');

sigma2 = zeros(stdsize);
for I = 1:nsubj
    subject_image = readvbm(subs4mean(I), 1);
    
    sigma2 = sigma2 + (subject_image - alphahat - agehat*Age(I) - sexhat*Sex(I)).^2;
    
    disp(I);
end

sigma2 = sigma2/(nsubj-3); %(n-p) in the denomimator, as p = 3!
sigma2 = sigma2.*vbm_mask; 

imgsave(sigma2, 'smooth_vbm_agesexlm_sigma2')

%%
fprintf('t calculation\n')
tage = nan(stdsize);
tsex = nan(stdsize);

for I = 1:91
    disp(I)
    for J = 1:109
        for K = 1:91
            tage(I,J,K) = agehat(I,J,K)/sqrt(sigma2(I,J,K)*agetdenom(I,J,K));
            tsex(I,J,K) = agehat(I,J,K)/sqrt(sigma2(I,J,K)*sextdenom(I,J,K));
        end
    end
end

imgsave(tage, 'smooth_vbm_agesexlm_tage')
imgsave(tsex, 'smooth_vbm_agesexlm_tage')

%%
% R2age = F2R(tage.^2,nsubj,3);
% imgsave(R2age,'smooth_vbm_agesexlm_R2age')
% 
% R2sex = F2R(tsex.^2,nsubj,3);
% imgsave(R2sex,'smooth_vbm_agesexlm_R2sex')

%%
nsubj = 4000;
tage = imgload('smooth_vbm_agesexlm_tage');
% tsex = imgload('smooth_vbm_agesexlm_tsex');

[R2age,f2age] = F2R(tage.^2,nsubj,3, 2); %Note that p-p_0 = 1 here, so R2age computed using the new F2R function is actually unchanged!
imgsave(R2age,'smooth_vbm_agesexlm_R2age',CSI);
imgsave(f2age,'smooth_vbm_agesexlm_f2age',CSI);

%%
tage = imgload('smooth_vbm_agesexlm_tage');
R2age = imgload('smooth_vbm_agesexlm_R2age');
Rage = sqrt(R2age).*sign(tage);

imgsave(Rage,'smooth_vbm_agesexlm_Rage');

% %%
% nsubj = 4000;
% tage = imgload('smooth_vbm_agesexlm_tage');
% % tsex = imgload('smooth_vbm_agesexlm_tsex');
% 
% [R2agenew,f2agenew] = F2R(tage.^2,nsubj,3, 2);
% imgsave(R2agenew,'smooth_vbm_agesexlm_R2agenew',CSI);
% imgsave(f2agenew,'smooth_vbm_agesexlm_f2agenew',CSI);
% 
% [R2ageold,~] = F2R(tage.^2,nsubj,3, 1);
% imgsave(R2ageold,'smooth_vbm_agesexlm_R2ageold',CSI);

% [R2sex,f2sex] = F2R(tsex.^2,nsubj,3, 2);
% imgsave(R2sex,'smooth_vbm_agesexlm_R2sex',CSI);
% imgsave(f2sex,'smooth_vbm_agesexlm_f2sex',CSI);

