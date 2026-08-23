@echo off
color 0a
title Rift Animation
:loop
cls

rem echo [1;31mRift Animation[0m
rem echo [1;34mLoading...[0m
rem timeout /t 1 >nul
echo [1;32mRift is opening...[0m
timeout /t 2 >nul
echo [1;35mRift is fully open![0m
timeout /t 3 >nul
echo [1;33mRift is closing...[0m
timeout /t 5 >nul
echo [1;31mRift is closed.[0m
timeout /t 6 >nul
goto loop