# Date Type Detector

A Rust-powered Python package that analyzes pandas DataFrames to detect columns containing date or timestamp strings.

## What it does

Tired of constantly fixing data types in your DataFrames? Or perhaps you'd like to automatically generate table definitions right after parsing CSV files you've never seen before? You've just found the tool that will make your life easier.

`date_type_detector` rapidly scans object-type columns in pandas DataFrames to determine if they contain date or timestamp data stored as strings. It considers a wide range of common date formats and can help automate the process of converting string date columns to proper datetime types.

Key features:
- Fast performance with Rust implementation
- Handles null values gracefully
- Recognizes multiple common date/datetime formats
- Returns a simple dictionary showing which columns likely contain date strings

## More info

For more information check my other repository https://github.com/msmch/date_type_detector.git