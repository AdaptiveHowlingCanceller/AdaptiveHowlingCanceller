// (c) 2025 cepstrum.co.jp
// howling canceller simulation program for Scilab
//
//  +----------------------------------------------------------------------+
//  |                                                                      |
//  |                                 s (speech signal)                    |
//  |                                 |                                    |
//  |                       +---+ d   v                                    |
//  |                  +--->| h +--->(+)---+ ds                            |
//  |                  |    +---+          |                               |
//  |    +---------+   |                 + v         +-----------------+   |
//  +--->| limiter +---+ x    ^           (+)---+--->| frequency shift +---+
//       +---------+   |      |          - ^    | e  +-----------------+ ze
//                     |    +---+          |    |
//                     +--->| w +----------+    |
//                          +---+ y             |
//                            |                 |
//                            +-----------------+

mprintf('*** simulation start ');

clear;                      // clear all variables

INPUT_WAVEFILE_NAME ='male_radio_noise_bpf.wav';
//INPUT_WAVEFILE_NAME ='english_source.wav';
OUTPUT_WAVEFILE_NAME='out.wav';

FS       =8000;                // sampling frequency [Hz]
ADPLEN   =256;                 // adaptive filter legnth
GAIN     =4.0;                 // maximum gain of acoustic system
MARGIN   =2.0;                 // dynamic range margin
//MU     =0.0;                 // step size parameter of adaptive filter (howling canceller off)
MU       =0.003;               // step size parameter of adaptive filter
//MU     =0.01;                // step size parameter of adaptive filter
HILLEN   =31;                  // Hilbert transform length
FREQ_SHIFT=5;                  // frequency shift [Hz]

indata=loadwave(INPUT_WAVEFILE_NAME);
indata=indata/max(abs(indata));
indata=indata/(GAIN*MARGIN);
DATLEN=length(indata);
DATLEN=DATLEN-modulo(DATLEN, 2);    // DATLEN should be even number
indata=indata(1:DATLEN);

outdata      =zeros(1:DATLEN);
outdata2     =zeros(1:DATLEN);
missalignment=zeros(1:DATLEN);
err          =zeros(1:DATLEN);

// generate impulse response of acoustice system (h1)
rand('normal');
rand('seed', 3456);
h1=rand(1:ADPLEN);
h1=h1.*(0.98^(1:ADPLEN));
h1=[zeros(1:10), h1(11:ADPLEN)]; 
h1=[zeros(1:10), h1(1:ADPLEN-10)];   // add more delay
h1=h1-sum(h1)/ADPLEN;            // remove DC offset
h1=h1/max(abs(fft(h1, -1)));
h1=GAIN*h1;                   // set gain of h1

// generate impulse response of acoustice system (h2)
rand('normal');
rand('seed', 1234567);
h2=rand(1:ADPLEN);
h2=h2.*(0.98^(1:ADPLEN));
h2=[zeros(1:5), h2(6:ADPLEN)];
h2=h2-sum(h2)/ADPLEN                // remove DC offset
h2=h2/max(abs(fft(h2, -1)));
h2=GAIN*h2;                   // set gain of h2

// generate hilbert transform FIR filter coefficient etc
hilbert_buf=zeros(1:HILLEN);
coef_i=zeros(1:HILLEN);
coef_q=zeros(1:HILLEN);
coef_i((HILLEN+1)/2)=1.0;
for i=1:(HILLEN-1)/2
  coef_q(i)=(2.0/%pi)*(1.0/i)*(sin(%pi*i/2.0)^2.0);
end
coef_q=[-mtlb_fliplr(coef_q(1:(HILLEN-1)/2.0)), 0, coef_q(1:(HILLEN-1)/2.0)];

buf=zeros(1:ADPLEN);
w  =zeros(1:ADPLEN);

h=h1;
ze=0.0;
for i=1:DATLEN 
  if i==DATLEN/2
    h=h2;           // change impulse response 
  end

  x=ze;

  // limiter
  if (MARGIN/GAIN)<abs(x)
    x=(MARGIN/GAIN)*sign(x);
  end

  buf=[x, buf(1:ADPLEN-1)];
  d=h*buf';
  s=indata(i);
  ds=d+s;
  y=w*buf';
  e=ds-y;
  
  // frequency shift
  hilbert_buf=[hilbert_buf(2:HILLEN), e];
  ze=(hilbert_buf*coef_i')*cos(2.0*%pi*FREQ_SHIFT*i/FS)'+(hilbert_buf*coef_q')*sin(2.0*%pi*FREQ_SHIFT*i/FS)';

  w=w+2*MU*e*buf;    // LMS algorithm

  outdata(i)=x;
  outdata2(i)=d;
  missalignment(i)=10.0*log10(sum(abs(w-h).^2)/sum(h.^2)+1e-10);
  err(i)=e-s;

  if modulo(i, FS)==0
    mprintf('>');
  end
end

savewave(OUTPUT_WAVEFILE_NAME, outdata, FS);

// plot input signal (s/indata)
scf(0);
clf;
title('input signal (s/indata)', 'fontsize', 3);
plot2d(1:DATLEN, indata, style=2, axesflag=1, rect=[0, -1, DATLEN, 1]);

// plot output signal of limiter (x)
scf(1);
clf;
title('limiter output (x)', 'fontsize', 3);
plot2d(1:DATLEN, outdata, style=2, axesflag=1, rect=[0, -1, DATLEN, 1]);

// plot missalignment of adaptive filter coefficient [dB]
scf(2);
clf;
title('miss alignment [dB]', 'fontsize', 3);
plot2d(1:DATLEN, missalignment, style=2, rect=[0, -20, DATLEN, 0], axesflag=1, rect=[0, -20, DATLEN, 10]);

// plot impulse response (h, w)
scf(3);
clf;
title('impulse response (blue-->h, red-->w)', 'fontsize', 3);
plot2d(1:ADPLEN, h, axesflag=1, style=2, rect=[0, -1, ADPLEN, 1]);       // blue
plot2d(1:ADPLEN, w, axesflag=1, style=5, rect=[0, -1, ADPLEN, 1]);       // red

// plot amplitude response of h, w [dB]
hspec=20.0*log10(abs(fft([h, zeros(1:(FS-ADPLEN))], -1))+1e-9);
hspec=hspec(1:FS/2);
wspec=20.0*log10(abs(fft([w, zeros(1:(FS-ADPLEN))], -1))+1e-9);
wspec=wspec(1:FS/2);
scf(4);
clf;
title('amplitude response [dB] (blue-->h  red-->w)', 'fontsize', 3);
plot2d(hspec, axesflag=1, style=2, rect=[0, -40, length(hspec), 20]);             // blue
plot2d(wspec, axesflag=1, style=5, rect=[0, -40, length(hspec), 20]);             // red

// PA output signal (d)
scf(5);
clf;
title('PA output signal (d)', 'fontsize', 3);
plot2d(1:DATLEN, outdata2, style=2, axesflag=1, rect=[0, -2, DATLEN, 2]);

scf(10);
clf;
title('impulse response (h1)', 'fontsize', 3);
plot2d(1:ADPLEN, h1, axesflag=1, style=2, rect=[0, -1, ADPLEN, 1]);       // blue

scf(11);
clf;
title('impulse response (h2)', 'fontsize', 3);
plot2d(1:ADPLEN, h2, axesflag=1, style=2, rect=[0, -1, ADPLEN, 1]);       // blue

// save impulse response (h)
fd=mopen('h1.txt', 'w');
for i=1:ADPLEN
  mfprintf(fd, '%f\n', h1(i));
end
mclose(fd);
fd=mopen('h2.txt', 'w');
for i=1:ADPLEN
  mfprintf(fd, '%f\n', h2(i));
end
mclose(fd);

mprintf(' finish');
