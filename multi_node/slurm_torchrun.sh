#!/bin/bash

#SBATCH --job-name=multinode-test

#SBATCH --ntasks=4

#SBATCH --nodes=4

#SBATCH --gpus-per-task=1

nodes=( $( scontrol show hostnames $SLURM_JOB_NODELIST ) )
nodes_array=($nodes)
head_node=${nodes_array[0]}
head_node_ip=$(srun --nodes=1 --ntasks=1 -w "$head_node" hostname --ip-address)

echo Node IP: $head_node_ip
export LOGLEVEL=INFO

srun torchrun \
--nnodes 4 \
--nproc_per_node 1 \
--rdzv_id $RANDOM \
--rdzv_backend c10d \
--rdzv_endpoint $head_node_ip:29500 \
./charnn/main.py dataset.path=/shared/data/input.txt +trainer.checkpoint_path=/shared/model/charnn.pt +trainer.log_dir=/shared/logs