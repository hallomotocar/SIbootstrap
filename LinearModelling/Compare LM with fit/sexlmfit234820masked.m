Sex = bbvars('Sex');
loc = 234820;

subs4mean = loaddata('subs4mean');
nsubj = length(subs4mean);

Y = zeros(1, nsubj);
Z = zeros(1, nsubj);

for I = 1:nsubj
    subject_image = readimg(subs4mean(I),'copes', 1);
    mask = readimg(subs4mean(I),'mask', 1);
    Y(I) = subject_image(loc);
    Z(I) = mask(loc);
    disp(I)
end

Y_available = Y(logical(Z));
Sex_available = Sex(logical(Z));

fit = fitlm(Sex_available, Y_available);

save(strcat(CSI,'availableat234820'),'Y_available', 'Sex_available')

save(strcat(CSI,'sexlmfit234820masked'), 'fit')
