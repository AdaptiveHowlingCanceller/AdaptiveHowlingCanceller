
adaptive howling canceller simulation program for Scilab
(adaptive acoustic feedback canceller simulation program for Scilab)

Scilab download ---> https://www.scilab.org/

------------------------------------------------------------------------------

simulation program and input wav file

  free, as is, no spesific license

    howling_canceller_simulation.sce           Scilab simulation program (delay decorrelator)
    howling_canceller_simulation_shift.sce     Scialb simulation program (frequency shift decorrelator)
    male_radio_noise_bpf.wav                   input wav file (Japanese)
    english_source.wav                         input wav file (Engliseh)

  use "exec" and "help" command in Scilab console (command line)

    >exec('howling_canceller_simulation.sce', -1);
    >exec('howling_canceller_simulation_shift.sce', -1);
    >help exec;

------------------------------------------------------------------------------

simulation result

  Japanese

    result_delay_decorrelator_mu0(howling_canceller_off).wav     howling canceller off (mu/MU=0)
    result_delay_decorrelator_mu0.005.wav                        mu/MU=0.005 (delay decorrelator)
    result_frequency_shift_decorrelator_mu0.003.wav              mu/MU=0.003 (frequency shift decorrelator)

  English

    english_howling_canceller_off.wav                            howling canceller off (mu/MU=0)
    english_result.wav                                           mu/MU=0.005 (delay decorrelator)

------------------------------------------------------------------------------

reference

  https://www.cepstrum.co.jp/rd/howling/english_page/howling_english_page.html
  https://www.cepstrum.co.jp/rd/howling/howling_canceller_simulation/howling_canceller_simulation.html
  https://www.cepstrum.co.jp/rd/howling/_pdf_download/howling_canceller_pdf_download.html
  https://www.cepstrum.co.jp/rd/howling/howling.html

------------------------------------------------------------------------------

(c) 2025 cepstrum.co.jp


