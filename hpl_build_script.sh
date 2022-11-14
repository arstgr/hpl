#!/bin/bash

export HPL_VERSION="2.3"

wdir=$(pwd)
module load gcc-9.2.0
module load mpi/hpcx
git clone https://github.com/flame/blis.git
cd blis/
git reset --hard ae10d9495486f589ed0320f0151b2d195574f1cf
mkdir libblis
libbls=$(pwd)/libblis
sed -i 's/COPTFLAGS      := -O2/COPTFLAGS      := -O2 -Ofast -ffast-math -ftree-vectorize -funroll-loops -march=znver2/' config/amd64/make_defs.mk
./configure --prefix=$libbls --enable-threading=openmp CC=gcc zen3
make 
make install
cd ../

wget --no-check-certificate https://www.netlib.org/benchmark/hpl/hpl-${HPL_VERSION}.tar.gz
tar -xzf hpl-${HPL_VERSION}.tar.gz
cd hpl-${HPL_VERSION}/
hpldir=$(pwd)
cd setup
sh make_generic
cp Make.UNKNOWN ../Make.Linux
cd ../
sed -i 's/ARCH         = UNKNOWN/ARCH         = Linux/' Make.Linux
sed -i 's,TOPdir       = $(HOME)/hpl'",TOPdir       = $hpldir," Make.Linux
sed -i 's,LAdir        ='",LAdir        = $libbls," Make.Linux
sed -i 's,LAinc        ='",LAinc        = -I$libbls/include/blis," Make.Linux
sed -i 's,LAlib        = -lblas'",LAlib        = $libbls/lib/libblis.a -lm," Make.Linux
sed -i 's/CCFLAGS      = $(HPL_DEFS)/CCFLAGS      = $(HPL_DEFS) -fomit-frame-pointer -O3 -funroll-loops -W -Wall -march=znver2 -mtune=znver2 -fopenmp/' Make.Linux
sed -i 's/LINKER       = mpif77/LINKER       = mpicc/' Make.Linux
sed -i 's/LINKFLAGS    =/LINKFLAGS    = $(CCFLAGS)/' Make.Linux
make arch=Linux

cd $wdir
cp $hpldir/bin/Linux/xhpl .

cat <<EOF > HPL.dat
HPLinpack benchmark input file
Innovative Computing Laboratory, University of Tennessee
HPL.out      output file name (if any)
6            device out (6=stdout,7=stderr,file)
1            # of problems sizes (N)
128000       #84480            Ns
1            # of NBs
232            NBs
0            PMAP process mapping (0=Row-,1=Column-major)
1            # of process grids (P x Q)
4           Ps
4            Qs
16.0         threshold
1            # of panel fact
2            PFACTs (0=left, 1=Crout, 2=Right)
1            # of recursive stopping criterium
4            NBMINs (>= 1)
1            # of panels in recursion
2            NDIVs
1            # of recursive panel fact.
2            RFACTs (0=left, 1=Crout, 2=Right)
1            # of broadcast
2            BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
1            # of lookahead depth
1            DEPTHs (>=0)
1            SWAP (0=bin-exch,1=long,2=mix)
64           swapping threshold
0            L1 in (0=transposed,1=no-transposed) form
0            U  in (0=transposed,1=no-transposed) form
1            Equilibration (0=no,1=yes)
8            memory alignment in double (> 0)
EOF


chmod +x appfile_ccx*
chmod +x xhpl_ccx.sh
chmod +x hpl_run_scr_*.sh
chmod +x hpl_pssh_script.sh
