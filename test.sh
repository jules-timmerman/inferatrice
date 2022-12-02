#!/bin/bash

check () {
	if [ "$(diff -q $1 $2)" ]
	then
		echo "failed !"
		exit 0
	else
		echo "passed !"
		rm $1
	fi
}


echo -n "2 = 2 ... "
echo "eq(2,2)." | ./inferatrice 2_arith.inf > test_data/eq22.txt
check "test_data/eq22.txt" "test_data/res_eq22.txt"

echo -n "X = 5 ... "
echo "eq(X,5)." | ./inferatrice 2_arith.inf > test_data/eqx5.txt
check "test_data/eqx5.txt" "test_data/res_eqx5.txt"

echo -n "X + Y = 2 ... "
echo "plus(X,Y,Z)." | ./inferatrice 2_arith.inf > test_data/plusXYZ.txt
check "test_data/plusXYZ.txt" "test_data/res_plusXYZ.txt"

echo -n "s() ... "
echo "s()." | ./inferatrice 1_order.inf > test_data/s_fail.txt
check "test_data/s_fail.txt" "test_data/res_s_fail.txt" 

echo -n "1 + X = 8 ... "
echo "plus(1,X,8)." | ./inferatrice 2_arith.inf > test_data/plus1X8.txt
check "test_data/plus1X8.txt" "test_data/res_plus1X8.txt"

echo -n "1 + Y + 3 = W ... "
echo "plus(1,Y,3,W)." | ./inferatrice 2_arith.inf > test_data/plus1Y3W.txt
check "test_data/plus1Y3W.txt" "test_data/res_plus1Y3W.txt"

echo -n "10 - 5 = 5 ... "
echo "moins(10,5,5)." | ./inferatrice 2_arith.inf > test_data/moins1055.txt
check "test_data/moins1055.txt" "test_data/res_moins1055.txt"

echo -n "4 - X = 5 ... "
echo "moins(4,X,5)." | ./inferatrice 2_arith.inf > test_data/moins4X5.txt
check "test_data/moins4X5.txt" "test_data/res_moins4X5.txt"

echo -n "27 < 36 ... "
echo "lt(27,36)." | ./inferatrice 2_arith.inf > test_data/lt2736.txt
check "test_data/lt2736.txt" "test_data/res_lt2736.txt"

echo -n "15 = 30 / 2 ... "
echo "half(30,15)." | ./inferatrice 2_arith.inf > test_data/half3015.txt
check "test_data/half3015.txt" "test_data/res_half3015.txt"

echo -n "8 est pair ... "
echo "even(8)." | ./inferatrice 2_arith.inf > test_data/even8.txt
check "test_data/even8.txt" "test_data/res_even8.txt"

echo -n "9 n'est pas pair ... "
echo "even(9)." | ./inferatrice 2_arith.inf > test_data/even9.txt
check "test_data/even9.txt" "test_data/res_even9.txt"

echo -n "Ackermann(3,3) = 61 ... "
echo "ack(3,3,X)." | ./inferatrice 2_arith.inf > test_data/ack33.txt
check "test_data/ack33.txt" "test_data/res_ack33.txt"

echo -n "X - 7 < 10 ... "
echo "moins(X,7,W), lt(W,10)." | ./inferatrice 2_arith.inf > test_data/Xmoins7inf10.txt
check "test_data/Xmoins7inf10.txt" "test_data/res_Xmoins7inf10.txt"
