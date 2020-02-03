@echo off

IF "%1%"=="t" (
  mpc toggle
)

IF "%1%"=="n" (
  mpc next
)

IF "%1%"=="p" (
  mpc prev
)

IF "%1%"=="f" (
  mpc seek +10
)

IF "%1%"=="b" (
  mpc seek -10
)