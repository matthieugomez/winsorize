The command `winsorize` winsorizes observations based  5 times the interquartile.

- With the option `replace`, variable is replaced by top coded one. With the option `gen`, a new variable is created
- with the option `p(pmin pmax)`, outliers are defined as the values  below and above the specified percentiles,  than five times the interquartile. A `pmin` or `pmax` specified as `.` can be used to avoid top coding in one direction
- with the option `missing`, outliers are replaced by missing values rather than top coded
- with the option `by`, outliers are defined within groups defined by the variable `by`


The overall syntax is 

```
winsorize [varlist] [if] [in] [, p(pmin pmax) replace gen(varlist) missing by(varname)]
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