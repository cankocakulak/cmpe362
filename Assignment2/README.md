# Stock Trading Strategy Analysis

This project implements a quantitative trading strategy using Digital Signal Processing (DSP) techniques to analyze and trade  bank stocks. The strategy uses multiple technical indicators to make trading decisions.

## Project Structure

```
Assignment2/
├── data/                  # Contains stock data files
│   ├── HDFCBANK.csv
│   ├── ICICIBANK.csv
│   ├── INDUSINDBK.csv
│   └── KOTAKBANK.csv
├── logs/                  # Output directory for trade logs and money tracking
├── plots/                 # Output directory for generated plots
├── compute_ema.m          # Exponential Moving Average calculation
├── compute_rsi.m          # Relative Strength Index calculation
├── compute_sma.m          # Simple Moving Average calculation
├── read_and_plot_vwap.m   # Basic VWAP plotting
├── rsi_plot.m            # RSI indicator visualization
├── sma_ema_plot.m        # SMA and EMA indicators visualization
├── run_trading_strategy.m # Main trading strategy implementation
└── simulate_all_stocks.m  # Runs strategy on all stocks and generates reports
```

## File Descriptions

### Core Functions
- `compute_sma.m`: Implements Simple Moving Average (FIR filter)
- `compute_ema.m`: Implements Exponential Moving Average (IIR filter)
- `compute_rsi.m`: Implements Relative Strength Index calculation

### Visualization Scripts
- `read_and_plot_vwap.m`: Basic VWAP price plotting
- `rsi_plot.m`: Generates RSI indicator plots with overbought/oversold levels
- `sma_ema_plot.m`: Generates SMA and EMA indicator plots

### Trading Strategy
- `run_trading_strategy.m`: Implements the trading strategy using:
  - Multiple timeframe SMA analysis (10, 20, 50 days)
  - EMA for trend detection
  - RSI for overbought/oversold conditions
  - Price momentum for trend confirmation
- `simulate_all_stocks.m`: Runs the strategy on all stocks and generates:
  - Trade logs
  - Money tracking CSV files
  - Performance plots

## How to Run

1. **Setup**
   - Ensure MATLAB is installed
   - Place all CSV files in the `data/` directory
   - Create `logs/` and `plots/` directories (they will be created automatically if missing)

2. **Generate Technical Indicator Plots**
   ```matlab
   % Run in MATLAB
   sma_ema_plot
   rsi_plot
   ```
   This will generate plots in the `plots/` directory showing:
   - SMA and EMA indicators
   - RSI with overbought/oversold levels

3. **Run Trading Strategy**
   ```matlab
   % Run in MATLAB
   simulate_all_stocks
   ```
   This will:
   - Run the trading strategy on all stocks
   - Generate trade logs in `logs/` directory
   - Create money tracking CSV files
   - Generate performance plots

## Output Files

### Logs Directory
- `[stock_name]_log.txt`: Trade execution logs
- `money_[stock_name].csv`: Daily money tracking data

### Plots Directory
- `[stock_name]_sma_ema.png`: SMA and EMA indicator plots
- `[stock_name]_rsi.png`: RSI indicator plots
- `individual_stocks_comparison.png`: Individual stock performance
- `combined_net_worth_comparison.png`: Combined performance comparison
- `[stock_name]_net_worth.png`: Individual stock net worth over time

## Strategy Details

The trading strategy uses:
1. **Multiple Timeframe Analysis**
   - 10-day SMA for short-term trend
   - 20-day SMA for medium-term trend
   - 50-day SMA for long-term trend

2. **Trend Detection**
   - EMA for responsive trend signals
   - Price momentum for trend confirmation

3. **Risk Management**
   - RSI for overbought/oversold conditions
   - Dynamic position sizing based on trend strength

4. **Entry/Exit Rules**
   - Buy: Multiple confirmations required (trend, momentum, RSI)
   - Sell: Trend reversal or overbought conditions with momentum reversal

## Notes
- The strategy uses the last 600 days of data for trading
- Initial capital is 10,000 currency units
- Fractional shares are allowed
- No lookahead is used in the strategy
