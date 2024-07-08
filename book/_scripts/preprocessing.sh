#!/bin/bash

# Define the languages and their respective build directories
LANGUAGES=("en" "ko")
LANGUAGE_NAMES=("English" "한국어")
FINAL_BUILD_DIR="book/_build/html"
LANGUAGE_SELECTOR_FILE="book/_addons/language_selector.html"
LANGUAGE_SELECTOR_CSS_FILE="book/_addons/language_selector.css"
REDIRECT_INDEX_FILE="book/_addons/language_redirect.html"
FINAL_INDEX_FILE="$FINAL_BUILD_DIR/index.html"

# Function to copy and modify HTML files
copy_and_modify_html() {
    local lang=$1
    local lang_name=$2
    local src_dir=$3
    local dest_dir=$4

    mkdir -p "$dest_dir"
    cp -R "$src_dir"/* "$dest_dir"

    # Create language selector content
    local selector_content
    selector_content=$(cat "$LANGUAGE_SELECTOR_FILE")

    # Remove new lines
    selector_content="${selector_content//$'\n'/}"

    # Replace current language
    selector_content="${selector_content/__CURRENT_LANGUAGE__/$lang_name}"

    # Create language options
    local options=""
    for i in "${!LANGUAGES[@]}"; do
        local l=${LANGUAGES[$i]}
        local name=${LANGUAGE_NAMES[$i]}
        options+="          <li><a href=\"#\" onclick=\"switchLanguage('$l'); return false;\">$name</a></li>"
    done

    # Replace language options
    selector_content="${selector_content/__LANGUAGE_OPTIONS__/$options}"

    # Modify HTML files
    find "$dest_dir" -name "*.html" -print0 | while IFS= read -r -d '' html_file; do
        # Add language selector and script
        awk -v selector="$selector_content" '
        /<\/head>/ {
            print "    <script src=\"/_static/language_switcher.js\"></script>"
            print $0
            next
        }
        /<div class="sidebar-primary-items__start sidebar-primary__section">/ {
            print $0
            print selector
            next
        }
        {print}
        ' "$html_file" >"${html_file}.tmp" && mv "${html_file}.tmp" "$html_file"
    done
}

# Main execution
echo "Starting post-processing..."

# Create final build directory
mkdir -p "$FINAL_BUILD_DIR"

# Copy and modify files for each language
for i in "${!LANGUAGES[@]}"; do
    lang=${LANGUAGES[$i]}
    lang_name=${LANGUAGE_NAMES[$i]}
    echo "Processing $lang..."
    src_dir="book/${lang}/_build/html"
    dest_dir="${FINAL_BUILD_DIR}/${lang}"
    echo "Copying and modifying HTML files..."
    copy_and_modify_html "$lang" "$lang_name" "$src_dir" "$dest_dir"
done

# Copy and modify redirect index file
echo "Copying and modifying redirect index file..."
cp -f "$REDIRECT_INDEX_FILE" "$FINAL_INDEX_FILE"

# Update the supported languages in the redirect file
sed -i.bak 's/var supportedLangs = \["en", "ko"\];/var supportedLangs = ["en", "ko"];/' "$FINAL_INDEX_FILE"

# Remove backup file
rm "${FINAL_INDEX_FILE}.bak"

echo "Post-processing complete!"