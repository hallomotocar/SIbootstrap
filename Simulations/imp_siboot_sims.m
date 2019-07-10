function imp_siboot_sims( nsubj, type, effectsize, sim_tot )
% IMP_SIBOOT_SIMS( nsubj, type, effectsizescale ) implements the
% simulations for the SIbootstrap paper.
%--------------------------------------------------------------------------
% ARGUMENTS
% nsubj             the number of subjects
% type              the type either T, R2, t4lm or mean
% effectsize        the effectsize of the maxima
% sim_tot           the total number of iterations
%--------------------------------------------------------------------------
% AUTHOR: Sam Davenport.
if nargin < 4
    sim_tot = 1000;
end
std_dev = 1;
B = 100;
FWHM = 3;

if strcmp(type, 'R2')
    [effectsizescale, ~] = matchsimspowerCD2R2( effectsize );
else
    effectsizescale = effectsize;
end
%We'll take CD = 0.1:0.1:0.6;

for Jmax = 1:sim_tot
    calcests_sims_thresh(type, nsubj, Jmax, FWHM, std_dev, B, effectsizescale)
end

end

