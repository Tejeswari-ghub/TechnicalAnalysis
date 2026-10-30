# BDA400 Assignment 2 — Technical Analysis (preliminary stage)
# Run from the Assignment2 directory. Internet required for Yahoo Finance.
required <- c('quantmod', 'TTR')
missing <- required[!vapply(required, requireNamespace, logical(1), quietly=TRUE)]
if (length(missing)) stop('Install packages first: install.packages(c("', paste(missing, collapse='", "'), '"))')

read_portfolio <- function(path='portfolio.txt') {
  if (!file.exists(path)) stop('Missing portfolio file: ', path)
  symbols <- trimws(readLines(path, warn=FALSE))
  symbols <- unique(symbols[nzchar(symbols) & !grepl('^#', symbols)])
  if (!length(symbols)) stop('Portfolio is empty')
  symbols
}

load_stock_data <- function(symbols, from=Sys.Date()-365, to=Sys.Date()) {
  out <- list()
  for (symbol in symbols) {
    tryCatch({
      raw <- quantmod::getSymbols(symbol, src='yahoo', from=from, to=to,
                                  auto.assign=FALSE, warnings=FALSE)
      if (NROW(raw)==0) stop('No rows returned')
      df <- data.frame(Date=as.Date(zoo::index(raw)), zoo::coredata(raw),
                       check.names=FALSE)
      names(df) <- c('Date','Open','High','Low','Close','Volume','Adjusted')[seq_len(ncol(df))]
      out[[symbol]] <- df
    }, error=function(e) warning(sprintf('%s: %s',symbol,conditionMessage(e))))
  }
  if (!length(out)) stop('No stock data downloaded; check connection and symbols')
  out
}

# Statistical mode is not base::mode (which reports storage type).
# With mostly unique continuous prices, the modal value may be uninformative.
statistical_mode <- function(x) {
  x <- x[is.finite(x)]
  if (!length(x)) return(NA_real_)
  counts <- table(x)
  if (max(counts)==1L) return(NA_real_)
  as.numeric(names(counts)[which.max(counts)])
}

calculate_statistics <- function(df, symbol, window=20L) {
  stopifnot('Close' %in% names(df), window >= 2)
  close <- as.numeric(df$Close)
  good <- close[is.finite(close)]
  if (!length(good)) stop('No valid close prices: ', symbol)
  ma <- TTR::SMA(close, n=window)
  data.frame(Symbol=symbol, Observations=length(good), Mean=mean(good),
             Median=median(good), Mode=statistical_mode(good),
             SD=if(length(good)>1) sd(good) else NA_real_,
             Latest_Close=tail(good,1), Latest_SMA=tail(ma,1),
             stringsAsFactors=FALSE)
}

display_stock_data <- function(data, n=6L) {
  for (symbol in names(data)) {
    cat('\n===== ',symbol,' =====\n',sep='')
    print(utils::head(data[[symbol]], n))
    cat('Rows:',nrow(data[[symbol]]),'\n')
  }
}

plot_stock <- function(df, symbol, window=20L, folder='figures') {
  dir.create(folder, showWarnings=FALSE, recursive=TRUE)
  file <- file.path(folder, paste0(symbol,'_closing_prices.png'))
  grDevices::png(file, width=1100, height=650, res=130)
  on.exit(grDevices::dev.off(), add=TRUE)
  close <- as.numeric(df$Close)
  ma <- TTR::SMA(close, n=window)
  plot(df$Date, close, type='l', col='#2367a0', lwd=2,
       xlab='Trading date', ylab='Closing price (USD)',
       main=paste(symbol,'Daily close and',window,'day simple moving average'))
  lines(df$Date, ma, col='#d9822b', lwd=2)
  legend('topleft', legend=c('Daily close',paste0(window,'-day SMA')),
         col=c('#2367a0','#d9822b'), lty=1, lwd=2, bty='n')
  invisible(file)
}

run_analysis <- function() {
  symbols <- read_portfolio()
  data <- load_stock_data(symbols)
  display_stock_data(data)
  stats <- do.call(rbind, lapply(names(data), function(s) calculate_statistics(data[[s]],s)))
  rownames(stats) <- NULL
  cat('\n===== SUMMARY STATISTICS =====\n'); print(stats, row.names=FALSE)
  for (s in names(data)) plot_stock(data[[s]],s)
  utils::write.csv(stats,'statistics.csv',row.names=FALSE)
  invisible(list(data=data, statistics=stats))
}

if (sys.nframe()==0L) run_analysis()
