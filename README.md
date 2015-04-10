The command `clean` windorizes observations based on 5 times the interquartile

- with the option `drop`, outliers are replaced by missing values rather than top coded
- with the option `p`, specified percentiles are used instead of five times the interquartile

```
sysuse nlsw88.dta, clear
clean hours, p(1 99)
```

