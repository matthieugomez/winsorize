The command `clean` windorizes observations based  5 times the interquartile

Moreover, several options are available
- with the option `p(pmin pmax)`, values that below and above the specified percentiles are top coded (rather than five times the interquartile). `pmin` or `pmax` can be `.` to mean no top coding.
- with the option `drop`, outliers are  dropped (i.e. replaced by missing values) rather than top coded
- with the option `by`, outliers are defined within groups defined by the variable `by`


The overall syntax is 

```
winsorize [varlist] [if] [in] [, p(pmin pmax) replace gen(varlist) drop by(varname)]
```

```
sysuse nlsw88.dta, clear
winsorize hours, replace
winsorize hours, p(1 99) replace
winsorize hours, p(. 99) replace
winsorize hours, gen(newhours)

```


## Installation
```
net install winsorize, from(https://github.com/matthieugomez/winsorize.ado/raw/master/)
```

If you have a version of Stata < 13, you need to install it manually

1. Click the "Download ZIP" button in the right column to download a zipfile. 
2. Extract it into a folder (e.g. ~/SOMEFOLDER)
3. Run

	```
	cap ado uninstall winsorize
	net install winsorize, from("~/SOMEFOLDER")
	```