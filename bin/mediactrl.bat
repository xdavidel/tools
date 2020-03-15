@echo off

IF "%1%"=="t" (
  mpc.lnk toggle
)

IF "%1%"=="n" (
  mpc.lnk next
)

IF "%1%"=="p" (
  mpc.lnk prev
)

IF "%1%"=="f" (
  mpc.lnk seek +10
)

IF "%1%"=="b" (
  mpc.lnk seek -10
)