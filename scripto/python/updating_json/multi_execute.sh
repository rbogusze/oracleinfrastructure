#!/bin/bash

python main.py t0 &
python main.py t1 &
python main.py t2 &
python main.py t3 &
python main.py t4 &
python main.py t5 &
python main.py t6 &
python main.py t7 &
python main.py t8 &
python main.py t9 &
wait $(jobs -p)
