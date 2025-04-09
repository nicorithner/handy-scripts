#/bin/bash
set -e

echo "Starting advanced PDF compression..."
mkdir -p compressed

format_size() {
  bytes=$1
  if [ $bytes -ge 1000000000 ]; then
    echo "$(echo "scale=2; $bytes/1000000000" | bc) GB"
  elif [ $bytes -ge 1000000 ]; then
    echo "$(echo "scale=2; $bytes/1000000" | bc) MB"
  else
    echo "$(echo "scale=2; $bytes/1000" | bc) KB"
  fi
}

compress_pdf() {
  input="$1"
  output="$2"

  gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
    -dPDFSETTINGS=/screen \
    -dColorConversionStrategy=/RGB \
    -dDownsampleColorImages=true -dColorImageResolution=100 \
    -dDownsampleGrayImages=true -dGrayImageResolution=100 \
    -dDownsampleMonoImages=true -dMonoImageResolution=300 \
    -dEmbedAllFonts=false \
    -dSubsetFonts=true \
    -dAutoRotatePages=/None \
    -dColorImageDownsampleType=/Bicubic \
    -dGrayImageDownsampleType=/Bicubic \
    -dMonoImageDownsampleType=/Subsample \
    -dJPEGQ=40 \
    -dNOPAUSE -dQUIET -dBATCH \
    -sOutputFile="$output" "$input"
}

processed=0
reduced=0

for file in *.pdf; do
  [ -f "$file" ] || continue

  base="${file%.*}"
  output_file="compressed/${base}_compressed.pdf"
  original_size=$(stat -f%z "$file")

  echo "Processing: $file ($(format_size $original_size))"

  # First pass: Basic compression
  compress_pdf "$file" "$output_file"

  # Second pass: Linearize and optimize if still too large
  new_size=$(stat -f%z "$output_file")
  if [ $new_size -ge $((original_size * 80 / 100)) ]; then
    echo "Applying aggressive second pass..."
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
      -dPDFSETTINGS=/screen \
      -dColorImageResolution=72 \
      -dGrayImageResolution=72 \
      -dMonoImageResolution=150 \
      -dJPEGQ=30 \
      -dOptimize=true \
      -dCompressPages=true \
      -dNOPAUSE -dQUIET -dBATCH \
      -sOutputFile="${output_file}.tmp" "$output_file"
    mv "${output_file}.tmp" "$output_file"
  fi

  # Final check
  new_size=$(stat -f%z "$output_file")
  processed=$((processed + 1))

  if [ $new_size -lt $original_size ]; then
    reduced=$((reduced + 1))
    echo "✅ Reduced to $(format_size $new_size) ($((100 - (new_size * 100 / original_size)))% savings)"
  else
    echo "⚠️  Using alternative compression..."
    # Fallback to qpdf for structural optimization
    qpdf --linearize --object-streams=generate "$file" "$output_file"
    echo "Final size: $(format_size $(stat -f%z "$output_file"))"
  fi
done

echo "-----------------------------------"
echo "Processed $processed PDF files"
echo "Successfully reduced size for $reduced files"
echo "-----------------------------------"
