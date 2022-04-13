# HPL Benchmarking
Scripts for automatic build of HPL on Azure HPC VMs, and single VM benchmarking on a PBS cluster

## Getting Started

### Dependencies

* gcc compilers
* HPC-X MPI library (or any other MPI Library available)

### Building HPL
To buil HPL, simply run 

```
sh hpl_build_script.sh 
```

To run a set of single VM test on a PBS cluster, modify the line '#PBS -J 1-64' and adjust it to the number of available VMs on the cluster, then submit the script

```
qsub array_hpl_run_scr.pbs
```

### Note:
Currently tested only on HBv2 and HBv3 VMs.

## Output

A summary of the results is printed in
```
hpl-test-results.log
```


