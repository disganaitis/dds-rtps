#!/bin/bash

cur_time=$(date +%F_%H-%M-%S)

out_dir=./outputs/

argcount=0

while getopts ":x:p:s:o:h" opt; do
    argcount=$(( argcount + 1 ))
    if [[ -v OPTARG ]]
    then
        argcount=$(( argcount + 1 ))
    fi
    case $opt in
        x)
            exec_dir=$OPTARG
            ;;
        p)
            pub=$OPTARG
            ;;
        s)
            sub=$OPTARG
            ;;
        o)
            out_dir=$OPTARG
            ;;
        h)
            echo "run_dockers.sh [OPTIONS]"
            echo "  -x must be provided"
            echo "  -x directory containing executables that will be iterated over"
            echo "  -p publisher executable(should be within the executables directory)"
            echo "  -s subscriber executable(should be within the executables directory)"
            echo
            echo "  if -p/-s are provided run_dockers will use -x for the other half"
            echo "  e.g. -x dir contains x y z, -p is x, -s is x"
            echo "  x/x x/y x/z y/x z/x will be the only combinations run"
            exit 1
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument" >&2
            exit 1
            ;;
    esac
done

shift $(( argcount ))
if [[ $1 == "--" ]]
then
    shift
fi

if [[ ! -d $exec_dir ]]
then
    echo "-x must be provided and must be a valid directory"
    exit 1
fi

if [[ -v pub ]]
then
    pub=$(basename $pub)
    if [[ ! -x $exec_dir/$pub ]]
    then
        echo "-p must be an executable within the -x directory"
        exit 1
    fi
fi

if [[ -v sub ]]
then
    sub=$(basename $sub)
    if [[ ! -x $exec_dir/$sub ]]
    then
        echo "-s must be an executable within the -x directory"
        exit 1
    fi
fi

mkdir -p $out_dir

execs=($(ls $exec_dir))

i=0
for pub_exe in "${execs[@]}"
do
    for sub_exe in "${execs[@]}"
    do
        if [[ ( ( ! -v pub ) && ( ! -v sub ) ) || ( -v pub && $pub == $pub_exe ) || ( -v sub && $sub == $sub_exe ) ]]
        then
            docker network create -d bridge --subnet=192.168.$i.0/24 bridge-$pub_exe-$sub_exe
            i=$(( i + 1 ))
            docker run --name "$cur_time"_dds-rtps_"$pub_exe"_"$sub_exe" --network=bridge-$pub_exe-$sub_exe -v $exec_dir:/opt/executables:ro -v $out_dir:/opt/outputs dds-rtps_runner $pub_exe $sub_exe $@ &
        fi
    done
done
