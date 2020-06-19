#!/bin/bash

#### CONFIG ####
ITERATION=10
BITSTREAM=../../../../../../kit/Test_Materials/Test_Signals/buildingblocks/ims_ade_fs48000_fri13_ssg_static_ade_md_20k_support.ac4
BS_DURATION=6.016

if [ -n "$1" ]; then
    ITERATION=$1
fi

######### REF ########
ref_cycles=0

cd /home/linaro/clu/work/clu_ac4dec_lin/rel/v2.3.1/dlb_ac4declib/Source_Code/dlb_ac4declib/make/ac4dec_v2_test/linux_arm64_gnu

for i in $(seq ${ITERATION}); do
    # The numbers are stored in the file profile_report.log
    taskset -c 1 ./ac4dec_v2_test_armv8float_neon_std_dlb_profile -pres_num 65535 -main_assoc_pref 0 -dap_enable 1 -drc_enable 1 -out_vspk_ang 10 -loud_pres_dial_enh 0 -out_bw_mode 20KHZ_BW -out_ch_cfg HEADPHONE -out_ref_lev -16 -drc_ref_lev -14 -out_ieq_strength 6 -out_ieq_prof off -if ${BITSTREAM} -of ngcdec-8828_ref.wav -dial_enh 3
    # The number (cycles) in under the node decoder_process
	tmp=$(grep -A 1 decoder_process profile_report.log | grep cycles | awk '{print $(NF-1)}')
    ref_cycles=$[ref_cycles+tmp]
done

ref_avg=$[ref_cycles/ITERATION]

######### DUT ########
dut_cycles=0

cd /home/linaro/clu/work/clu_ac4dec_lin/dev/fdn_update/dlb_ac4declib/Source_Code/dlb_ac4declib/make/ac4dec_v2_test/linux_arm64_gnu

for i in $(seq ${ITERATION}); do
    # The numbers are stored in the file profile_report.log
    taskset -c 1 ./ac4dec_v2_test_armv8float_neon_std_dlb_profile -pres_num 65535 -main_assoc_pref 0 -dap_enable 1 -drc_enable 1 -out_vspk_ang 10 -loud_pres_dial_enh 0 -out_bw_mode 20KHZ_BW -out_ch_cfg HEADPHONE -out_ref_lev -16 -drc_ref_lev -14 -out_ieq_strength 6 -out_ieq_prof off -if ${BITSTREAM} -of ngcdec-8828_dut.wav -dial_enh 3
    # The number (cycles) in under the node decoder_process
	tmp=$(grep -A 1 decoder_process profile_report.log | grep cycles | awk '{print $(NF-1)}')
    dut_cycles=$[dut_cycles+tmp]
done

dut_avg=$[dut_cycles/ITERATION]


######## SUMMARY ########
echo "REF avg cycles: ${ref_avg}"
echo "DUT avg cycles: ${dut_avg}"

## Calculate the MCPS
ref_mcps=$(echo print ${ref_avg}/${BS_DURATION}/1000000.0 | python)
dut_mcps=$(echo print ${dut_avg}/${BS_DURATION}/1000000.0 | python)
echo "REF MCPS: ${ref_mcps}"
echo "DUT MCPS: ${dut_mcps}"

## Calculate the delta
increase=$(echo print ${dut_mcps}-${ref_mcps} | python)
increase=$(echo print ${increase}/${ref_mcps}*100.0 | python)
echo "Increase is: ${increase}%"
