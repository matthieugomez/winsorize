The command `winsorize` windorizes observations based on 5 times the interquartile
- with the option `bottom` and `top`, specified percentiles are used instead of five times the interquartile
- with the option `drop`, outliers are replaced by missing values rather than top coded
- Syntax is `winsorize [varlist] [if] [in] [, by(varname) bottom(number) top(number) replace drop]`

```
sysuse nlsw88.dta, clear
winsorize hours, bottom(1) top(99) replace
winsorize hours, top(99) replace
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