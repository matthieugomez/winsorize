The command `clean` windorizes observations based on 5 times the interquartile

- with the option `drop`, outliers are replaced by missing values rather than top coded
- with the option `p`, specified percentiles are used instead of five times the interquartile

```
sysuse nlsw88.dta, clear
clean hours, p(1 99) replace
```


## Installation
```
net install clean, from(https://github.com/matthieugomez/stata-clean/raw/master/)
```

If you have a version of Stata < 13, you need to install it manually
Click the "Download ZIP" button in the right column to download a zipfile. Extract it into a folder (e.g. ~/SOMEFOLDER)
2. Run: (changing SOMEFOLDER with whatever you picked)
```
cap ado uninstall clean
net install clean, from("~/SOMEFOLDER")
```