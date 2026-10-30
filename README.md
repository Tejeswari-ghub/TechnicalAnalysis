# BDA400 Assignment 2 — Technical Analysis (Preliminary Stage)

Repository: `TechnicalAnalysis` • Folder: `Assignment2`

## Purpose
Download historical daily stock prices from Yahoo Finance using `quantmod`, calculate descriptive statistics and a 20-day simple moving average with `TTR`, and visualize closing prices.

## Files
- `portfolio.txt`: example ticker symbols (AAPL, MSFT, GOOGL).
- `R/install_packages.R`: installs the required packages.
- `R/analysis.R`: imports, analyzes, displays and plots stocks.
- `BDA400_Assignment2_Report.docx`: assignment report with screenshot placeholders.
- `figures/`: charts generated after running the script.
- `screenshots/`: add authentic screenshots from installation and execution.

## Run instructions
1. Install R and RStudio; open RStudio.
2. Set the working directory to `Assignment2` (Session > Set Working Directory > Choose Directory).
3. Run `source('R/install_packages.R')` once.
4. Run `source('R/analysis.R')` to load functions; then run `result <- run_analysis()`.
5. Review `statistics.csv`, the Console output and the PNG files in `figures/`.
6. Capture authentic screenshots and replace placeholders in the Word report.

**Data caveat:** Live Yahoo Finance data requires internet access and may change. Prices are not guaranteed; if downloads fail, check network access, symbols and provider availability. The mode of a continuous price series is reported as NA if all values are unique.

## Academic integrity
The documentation and example code were AI-assisted. Validate calculations and execution independently before submission. No claim is made that installations or live downloads were completed on the student's device.
