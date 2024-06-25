#!/bin/bash

# Define input and output file paths
input_file="dns.txt"
output_file="domain_names.txt"

# Use awk to extract domain names from the input file and save them to the output file
awk '/^[^;]/{print $1}' "$input_file" > "$output_file"

echo "Domain names extracted and saved to $output_file"
