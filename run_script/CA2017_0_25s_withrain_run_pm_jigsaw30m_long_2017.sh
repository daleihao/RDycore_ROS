#!/bin/bash
#SBATCH -t 48:00:00
#SBATCH --time-min=48:00:00
#SBATCH --constraint=cpu
#SBATCH --qos=regular
#SBATCH --nodes=20
#SBATCH --account=m3520


cd /global/cfs/cdirs/m4267/Dalei/RDycore/
source config/set_petsc_settings.sh --mach pm-cpu --config 3
cd /global/cfs/cdirs/m4267/Dalei/RDycore/input/CA2017_jigsaw_30m
time srun -n 2560 ../../build-pm-cpu-opt-32bit-gcc-11-2-0-v3.22.0/driver/rdycore CA2017.CriticalOutFlowBC_jigsaw_withrain_2month_long_dt_0_25s_pm_2017.yaml  \
-raster_rain_start_date 2017,1,1,0,0 \
-raster_rain_dir /global/cfs/cdirs/m4267/Dalei/RDycore/input/Rainfall_Rdycore/Rainfall/CA2017_whole_0K_P
