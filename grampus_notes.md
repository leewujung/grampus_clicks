# Analysis log: Grampus suction cup + far-field recording

## 2016/06/26
First try to sort out what was done last year in May. Two things seem to have been done:
1. filtering data with consecutive low-pass and high-pass filters to get rid of noise
2. use `call_marking_gui` to extract all clicks --> I remember it to work pretty well and very rarely mess up anything because the data SNR is very high for both the suction cup and far-field recordings

## 2016/06/27
Carfully looked through all the calibration data from Adam. Made a few slides to explain the problems to Whit (`\grampus_suction_cup\calibration_problems_20160627.pptx`). The bottom line is that the existing calibration data are not reliable and new calibration is needed.



## 2020/12/30
### Recap on expt info
- put all old analysis files under `grampus/analysis/analysis_2016`
- made a spreadsheet to record all timing info from the trials:
    - `trial_info.xlsx`
    - include date-session-throw matching of all audio (master-suctioncup and slave-farfield) and video (above and underwater) files
    - record the frame numbers for:
        - when the squid was thrown into water
        - when the dolphin was instructed to turn
- need to look into if the observed changes of beam pattern was before and after the dolphin turned and submerged its head underwater
    - crude quick check does show that the abrupt change of beamwidth happens as the dolphin made the "dive" to put its head underwater. For the two trials where I saw clear transition of beampattern: 20150426_am_throw1 and 20150427_am_throw1, the narrower beamwidth both showed up before the big gap in click sequence. Once the dolphin launged into the catch, the beamwidth was stable.
- seems that the story should be more about the beampattern in near and farfield instead of on the change of beamwidth







## TO-DO:
- Figuring out mic calibration data --> get relative compensation for each suction cup microphones
- Compensate for mic sensitivity to plot p2p pressure differences across the linear array
- Check if the above pattern differ depending on click amplitude (use one of the channels  for ref) or whether it's a click or buzz
- Plot click amplitude vs normalized click amplitudes across all channels
- Check if the above pattern changes along with the trial time (e.g., plot colored dots according to the actual click sequence), also see if there's categorical differences between regular clicks and buzzes
- Organize the data in different folder structure: top level is data type (mic, video, pics, etc.) and below that are data from each day
 
