% Define terms:
%
% mask - the full size grid controlling phase
% saw - the full size grid controlling amplitude
% screen - the full grid controlling both phase and amplitde

L = 6.04e-3;
lambda = 633e-9;
N = 256;
d = 8;
reducedN = floor(N/d);
[ii, jj] = ndgrid(1:N, 1:N);
numScreens = 1;
saveScreens = true;
doSim = false;

for dd = [512]
    for mm = [40]
        params = ScreenMakerParamStruct();

        params.screenType = 'mgsm';
        params.screenSize = N;
        params.numScreens = numScreens;
        params.M = mm;
        params.Corr_width_2 = dd;
        params.deltax = dd;
        params.Beta = mm;
        params.cosineShift = false;
        switch params.screenType
            case 'mgsm'
                %params.outputFolder = sprintf('Output\\Voelz_%d_D2_%d_M_%d\\', ...
                %    params.screenSize, params.M, params.Corr_width_2);
                params.outputFolder = sprintf('Output\\Pretty\\');
            case 'ring'
                params.outputFolder = sprintf('Output\\Voelz_%d_ring_B_%d_d_%d\\', ...
                    params.screenSize, params.Beta, params.deltax);
        end
        mkdir(params.outputFolder);


        %
        % Calculate the amplitude relations.
        %
        % Inverting f (to go from field ratios to h) is not quite as simple as
        % Voelz makes it out to be.
        %
        % I don't have much flexibility to pick U, and still get h to converge.  U
        % must be less than or equal to 1
        %
        % hbar = h/lambda;
        %

        U = 0.7*ones(reducedN,reducedN);
        % [rXX, rYY] = ndgrid(1:reducedN, 1:reducedN);
        % b = reducedN/2;
        % A = 0.7;
        % rr2 = ((rXX-reducedN/2).^2 + (rYY-reducedN/2).^2);
        % U = A*exp(-rr2/b^2);



        %f = @(x) sinc(pi*(1 - x/lambda)).*exp(-1i*pi*(1-x/lambda));
        f = @(x) sinc(pi*(1 - x));
        x0 = 0.1; % guess
        hbar = zeros(reducedN,reducedN);
        for k = 1:reducedN
            for j = 1:reducedN
                hbar(k, j) = fzero( @(x)(f(x)-U(k,j)), x0 ); 
            end
        end

        % syms x;
        % Functional inverse doesn't behave here
        % syms x;
        % f(x) = sin(pi*(1 - x/lambda))/(pi*(1-x/lambda))*exp(-1i*pi*(1-x/lambda));
        % finv = finverse(f, x);
        % h = double(finv(U));

        %h = zeros(reducedN,reducedN);


        [sawXX, sawYY] = ndgrid(linspace(0, 1, d), linspace(0, 1, d));
        sawTemplate = (sawXX+sawYY)*pi*2;

        saw = zeros(N, N);
        for k = 1:reducedN
            for j = 1:reducedN
                sawBlockXX = (k-1)*d + (1:d);
                sawBlockYY = (j-1)*d + (1:d);
                saw(sawBlockXX, sawBlockYY) = sawTemplate*hbar(k,j);
            end
        end
        sawPhase = saw;

        %
        % Correct the phase from the saw distortion
        %

        % meanPhase = sum(sawTemplate(:));
        % F = zeros(N, N);
        % for k = 1:reducedN
        %     for j = 1:reducedN
        %         sawBlockXX = (k-1)*d + (1:d);
        %         sawBlockYY = (j-1)*d + (1:d);
        %         F(sawBlockXX, sawBlockYY) = meanPhase*h(k,j);
        %     end
        % end
        % FPhase = F;
        F = zeros(N, N);
        for k = 1:reducedN
            for j = 1:reducedN
                sawBlockXX = (k-1)*d + (1:d);
                sawBlockYY = (j-1)*d + (1:d);
                F(sawBlockXX, sawBlockYY) = exp(-1i*pi*(1-hbar(k, j)));
            end
        end
        FPhase = angle(F);


        %
        % Calculate the phase relations.
        %

        %phaseCalc = 'uii convolution';
        phaseCalc = 'voelz fourier';

        kernel = kernelMaker(params);

        for k = 1:params.numScreens
            switch phaseCalc
                case 'voelz fourier'
                    sqrtPhi = fft2(kernel);

                    r = randn(N, N) + 1i*randn(N, N);
            %        mask = zeros(N, N);
            %         for m = 1:N
            %             for n = 1:N
            %                 mask = mask + r*sqrtPhi(m, n).*exp(1i*2*pi/N*m*ii).*exp(1i*2*pi/N*n*jj);
            %             end
            %         end
                    mask = ifft2(r.*sqrtPhi);


                case 'uii convolution'
                    cutIndices = N+(1:N);
                    I = zeros(3*N,3*N);
                    I(cutIndices, cutIndices) = exp(1i*2*pi*rand(N,N));

                    % convolution of window function with Gaussian Random Number 
                    mask = conv2(kernel,I,'same');
            end

            maskPhase = angle(mask);


            %
            % Put it all together
            %

            screen = mod(maskPhase, 2*pi);
            sawScreen = mod(maskPhase + sawPhase + FPhase, 2*pi);
            
            if saveScreens
                switch params.screenType
                    case 'mgsm'
                        figname = sprintf('%svoelz_mgsm_delta_%d_M_%d_num_%d.bmp',...
                            params.outputFolder, params.Corr_width_2, params.M, k);  
                    case 'ring'
                        figname = sprintf('%svoelz_ring_B_%d_d_%d_num_%d.bmp',...
                            params.outputFolder, params.Beta, params.deltax, k); 
                end
                
                
                imwrite(sawScreen/(2*pi),figname, 'bmp');
                figname = sprintf('%svoelz_mask_only_%d.bmp',...
                            params.outputFolder, k);  
                imwrite(maskPhase/(2*pi),figname, 'bmp');
                figname = sprintf('%svoelz_phase_only_%d.bmp',...
                            params.outputFolder, k); 
                imwrite(mod(sawPhase, 2*pi)/(2*pi),figname, 'bmp');
            end
        end
    end
end


%
% Simulation Stuff
%

if doSim

    upscaleFactor = 2;
    uN = upscaleFactor*N;
    uScreen = zeros(uN, uN);
    uSawScreen = zeros(uN, uN);
    patternInt = (0:(N-1))*upscaleFactor + 1;
    %[patternXX, patternYY] = ndgrid(patternInt, patternInt);
    for x = 0:(upscaleFactor-1)
        for y = 0:(upscaleFactor-1)
            uScreen(patternInt + x, patternInt + y) = screen;
            uSawScreen(patternInt + x, patternInt + y) = sawScreen;
        end
    end

    [uXX, uYY] = ndgrid((1:uN), (1:uN));



    b = uN/4;
    A = 1;
    rr2 = ((uXX-uN/2).^2 + (uYY-uN/2).^2);
    gBeam = A*exp(-rr2/b^2);
    uBeam = ones(size(rr2)); 
    beam = gBeam;
    beam = beam/sum(beam(:));

    noSawFarField = fftshift(fft2(exp(1i*uScreen).*beam));
    noSawFarIntensity = abs(noSawFarField).^2;

    sawFarField = fftshift(fft2(exp(1i*uSawScreen).*beam));
    sawFarIntensity = abs(sawFarField).^2;



    figure(1);
    clf;
    subplot(1, 2, 1)
    pcolor(abs(mask));
    shading flat
    title('mask magnitude')
    colorbar();
    subplot(1, 2, 2)
    pcolor(angle(mask));
    shading flat
    title('mask angle')
    colorbar();

    figure(2);
    clf;
    %subplot(1, 2, 1)
    pcolor(abs(saw));
    shading flat
    title('saw magnitude')
    colorbar();
    % subplot(1, 2, 2)
    % pcolor(angle(saw));
    % shading flat
    % title('saw angle')
    colorbar();

    figure(3);
    clf;
    subplot(1, 2, 1)
    pcolor(abs(sawScreen));
    shading flat
    title('screen magnitude')
    colorbar();
    subplot(1, 2, 2)
    pcolor(angle(sawScreen));
    shading flat
    title('screen angle')
    colorbar();

    maxIntensity = max(max(noSawFarIntensity(:)), max(sawFarIntensity(:)));

    figure(4)
    clf
    pcolor(noSawFarIntensity);
    shading flat
    title('no saw far field intensity');
    caxis([0 maxIntensity*1e-1])
    colorbar();

    figure(5)
    clf
    pcolor(sawFarIntensity);
    shading flat
    title('saw far field intensity');
    caxis([0 maxIntensity*1e-1])
    colorbar();
end