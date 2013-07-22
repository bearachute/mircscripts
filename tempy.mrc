alias tempy {
if ($2 isnum) {
if (F == $1) {
 msg $chan $2 in Fahrenheit is: $calc(($2 - 32) * 5/9) in Celsius
}
elseif (C == $1) {
 msg $chan $2 in Celsius is $calc($2 * (9/5) + 32) in Fahrenheit.
 }
}
}
