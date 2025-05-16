#!/usr/bin/env bash
set -euo pipefail # -u for nounset, -e for exit on error, -o pipefail for pipeline errors

# Script to generate a resume in DOCX and PDF formats using Pandoc.
#
# IMPORTANT:
# 1. This script is intended to be run from the directory where you want the
#    resume files to be saved.
# 2. For macOS users with Homebrew, it can attempt to install Pandoc and BasicTeX.
# 3. For other systems, please ensure Pandoc and a LaTeX distribution (with pdflatex)
#    are installed manually.

OUTPUT_BASENAME="resume_vikram_deshpande" # You can change this if needed
MARKDOWN_FILE="${OUTPUT_BASENAME}.md"
DOCX_FILE="${OUTPUT_BASENAME}.docx"
PDF_FILE="${OUTPUT_BASENAME}.pdf"

# --- Helper Functions ---
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if on macOS
is_macos() {
    [[ "$(uname)" == "Darwin" ]]
}

# --- Installation Helper Functions (macOS/Homebrew specific) ---
install_pandoc_brew() {
    if ! brew list pandoc >/dev/null 2>&1; then
        echo "Attempting to install Pandoc using Homebrew..."
        if brew install pandoc; then
            echo "Pandoc successfully installed via Homebrew."
        else
            echo "ERROR: Failed to install Pandoc via Homebrew. Please install it manually."
            return 1 # Use return code for functions
        fi
    else
        echo "Pandoc is already installed (according to Homebrew)."
    fi
    return 0
}

install_basictex_brew() {
    if ! brew list --cask basictex >/dev/null 2>&1; then
        echo "Attempting to install BasicTeX using Homebrew..."
        if brew install --cask basictex; then
            echo "BasicTeX successfully installed via Homebrew."
            echo "Updating PATH for TeX Live..."
            eval "$(/usr/libexec/path_helper)"
            echo "Attempting to update TeX Live manager (tlmgr). This may require sudo password."
            if check_command tlmgr; then
                if sudo tlmgr update --self; then
                    echo "TeX Live manager updated."
                else
                    echo "Warning: Failed to update TeX Live manager. PDF generation might still work."
                fi
            else
                echo "Warning: tlmgr command not found after BasicTeX install. Cannot update TeX Live manager."
            fi
        else
            echo "ERROR: Failed to install BasicTeX via Homebrew. Please install it manually."
            return 1
        fi
    else
        echo "BasicTeX is already installed (according to Homebrew)."
        # Optionally, offer to update tlmgr if BasicTeX is already installed
        if check_command tlmgr; then
            # Consider asking user if they want to update tlmgr if it's old, or just do it.
            # For simplicity, we'll just note it's installed. An update could be a separate user action.
            echo "If you encounter PDF issues, you might try: sudo tlmgr update --self --all"
        fi
    fi
    return 0
}


# --- Generic Installation Instructions ---
manual_install_instructions_pandoc() {
    echo "-----------------------------------------------------------------------"
    echo "ERROR: Pandoc not found."
    echo "Pandoc is required to generate resume documents."
    echo "To install Pandoc:"
    echo "  - On macOS (with Homebrew): brew install pandoc"
    echo "  - On Debian/Ubuntu: sudo apt-get update && sudo apt-get install pandoc"
    echo "  - On Fedora: sudo dnf install pandoc"
    echo "  - Other systems: See https://pandoc.org/installing.html"
    echo "Please install Pandoc and ensure it's in your PATH, then re-run the script."
    echo "-----------------------------------------------------------------------"
}

manual_install_instructions_latex() {
    echo "-----------------------------------------------------------------------"
    echo "INFO: pdflatex (LaTeX) not found or not in PATH."
    echo "LaTeX is required for PDF generation via Pandoc."
    echo "To install LaTeX:"
    echo "  - On macOS (with Homebrew):"
    echo "    - Full (large, recommended for fewer issues): brew install --cask mactex-no-gui"
    echo "    - Basic (smaller): brew install --cask basictex (this script can attempt this for you)"
    echo "      (BasicTeX might require manual installation of additional LaTeX packages)"
    echo "  - On Debian/Ubuntu: sudo apt-get update && sudo apt-get install texlive-latex-base texlive-fonts-recommended texlive-latex-extra texlive-plain-generic"
    echo "  - On Fedora: sudo dnf install texlive-scheme-basic"
    echo "  - Other systems: See https://www.latex-project.org/get/"
    echo "If you install LaTeX, ensure 'pdflatex' is in your PATH."
    echo "The script will attempt to create a .docx file, but PDF generation will be skipped if pdflatex is missing."
    echo "-----------------------------------------------------------------------"
}

# --- Main Logic ---
main() {
    echo "Starting resume generation process..."
    echo "Output directory: $(pwd)"
    echo "Output basename: ${OUTPUT_BASENAME}"
    echo

    local can_try_brew_install=false
    if is_macos && check_command brew; then
        can_try_brew_install=true
        echo "INFO: macOS detected with Homebrew. Will offer to install missing dependencies."
    elif is_macos && ! check_command brew; then
        echo "INFO: macOS detected, but Homebrew not found. Please install Homebrew (https://brew.sh) for automatic dependency installation, or install dependencies manually."
    fi
    echo

    # --- Dependency Check & Optional Installation: Pandoc ---
    echo "Checking for Pandoc..."
    if ! check_command pandoc; then
        if [ "$can_try_brew_install" = true ]; then
            if ! install_pandoc_brew; then exit 1; fi
            # Re-check after install attempt
            if ! check_command pandoc; then
                manual_install_instructions_pandoc
                exit 1
            fi
        else
            manual_install_instructions_pandoc
            exit 1
        fi
    fi
    echo "Pandoc found: $(command -v pandoc)"
    echo

    # --- Dependency Check & Optional Installation: LaTeX (pdflatex) ---
    local has_pdflatex=false
    echo "Checking for pdflatex (for PDF generation)..."
    if ! check_command pdflatex; then
        if [ "$can_try_brew_install" = true ]; then
            echo "pdflatex not found. Offering to install BasicTeX via Homebrew."
            # Ask user before proceeding with a large download/install like BasicTeX
            read -r -p "Do you want to attempt to install BasicTeX using Homebrew? (y/N): " response
            if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                if ! install_basictex_brew; then
                    echo "BasicTeX installation failed or was skipped. PDF generation might not work."
                    manual_install_instructions_latex # Show manual instructions as fallback
                fi
            else
                echo "Skipping BasicTeX installation."
                manual_install_instructions_latex
            fi
        else
            manual_install_instructions_latex # Show manual instructions if not macOS/brew
        fi
        # Re-check for pdflatex after potential install
        if check_command pdflatex; then
            has_pdflatex=true
        fi
    else
        has_pdflatex=true
    fi

    if [ "$has_pdflatex" = true ]; then
        echo "pdflatex found: $(command -v pdflatex)"
    else
        echo "Warning: pdflatex not found or installation skipped/failed. PDF generation will likely be skipped or fail."
    fi
    echo

    # --- Resume Content in Markdown ---
    # Using 'EOF' to prevent any variable expansion within the heredoc
    echo "Creating Markdown file: ${MARKDOWN_FILE}..."
    cat > "$MARKDOWN_FILE" <<'EOF'
# VIKRAM DESHPANDE
**AI Engineer / Iteration Manager / Delivery Lead**

sarkar.vikram@gmail.com • +61 433 224 556 • Melbourne, Australia \\
[LinkedIn](https://linkedin.com/in/vikramd-profile) • [GitHub](https://github.com/Victordtesla24)

---

## CAREER OBJECTIVE

Product-minded AI Engineer with 10+ years delivering high-stakes software in finance and health-adjacent domains. I specialise in designing and hardening LLM-powered services (chat, summarisation, function-calling agents) and the evaluation frameworks that keep them safe at scale. Combining a strong scientific mindset with battle-tested agile leadership, I build latency-critical, cloud-native systems that delight users while meeting governance, privacy and cost constraints.

---

## EDUCATION

*   **Master of Information Technology** — Monash University (Database Mgmt, Business Analysis, Project Mgmt) 2003–2007
*   **Bachelor of Engineering (Computer)** — Monash University 2008–2010

---

## TECHNICAL SKILLS

| Category         | Technologies                                                                                             |
|------------------|----------------------------------------------------------------------------------------------------------|
| LLM & ML         | LangChain / LangSmith • Langfuse • Phoenix • DeepEval • OpenAI / Anthropic APIs • Instructor-tuned LoRA models |
| Back-End         | TypeScript (Node.js 18) • Python 3.11 (FastAPI, Pydantic) • WebSocket streams • Express • Crypto (JOSE, JWT) |
| Front-End        | React 18 • Next.js 14 • Tailwind • ECharts • Zustand                                                     |
| Cloud & DevOps   | Vercel • Fly.io • Docker • GitHub Actions • Terraform • AWS Lambda & S3                                  |
| Data & MLOps     | Postgres • Supabase • Pandas • Prometheus & Grafana • CI/CD gating with automated LLM tests              |
| Agile Delivery   | Scrum / Kanban facilitation, backlog & roadmap ownership, $5 M+ programme budgets                        |

---

## WORK EXPERIENCE

### **AI Solutions Lead / Data Architect — ANZ**
*Melbourne • Sep 2017 – Present*

*   **LLM Evaluation & Observability** – Stood up end-to-end Langfuse + Phoenix stack to score hallucination, latency and cost across 180 k daily generations; reduced error budget breaches by 38 %.
*   **Realtime Telemetry Platform** – Authored > 6 k LOC TypeScript WebSocket server ([telemetry-server](https://github.com/Victordtesla24/telemetry-server)) handling 10 k+ concurrent cars; cut P95 latency to < 200 ms.
*   **Clinical-style Note Generator POC** – Prototyped GPT-4 function-calling agent that converts speech transcripts into SOAP notes; achieved 0.91 ROUGE-L vs clinician ground truth in pilot.
*   **Agile & Product Leadership** – Ran five squads (35 FTE) through discovery → GA for AI fraud-detection service; shipped on schedule, saving AU $2 M annual fraud losses.

### **Senior Project & Delivery Manager — ANZ**
*2017 – Present*

*   Led $4.2 M cloud migration, creating Kubernetes blue/green pipeline and automated GPU cost throttling—30 % opex reduction.
*   Instituted model-risk-management gates (bias, privacy, accessibility) into SDLC, passing all audit checkpoints.

### **Project & Analysis Lead — NAB**
*Nov 2016 – Aug 2017*

*   Delivered micro-service suite (Spring Boot + Kafka) that ingests 60 M events/day, enabling real-time credit-risk dashboards.

### **Senior Business Analyst — Microsoft 365**
*Oct 2015 – Oct 2016*

*   Conducted gap-analysis for Azure ML-driven telemetry; cut incident MTTR by 15 %.

*(Earlier roles at Telstra, InfoCentric & MYOB detail available on request)*

---

## OPEN-SOURCE & SIDE PROJECTS

*   **Public-Key-Server** – Node.js + Express service distributing PEM keys for Tesla Fleet API signing (100 % Mocha coverage).
*   **Relationship-Timeline-Feature** – React/TypeScript visualisation (86 % TS) showcasing D3-powered event arcs.
*   **Jira Analytics Dashboard** – Next.js + Supabase analytics app exposing sprint velocity and LLM-generated retro insights.

---

## CERTIFICATIONS

*   Certified ScrumMaster (CSM)
*   SAFe Agilist
*   AWS Certified Cloud Practitioner
*   TensorFlow Developer (Coursera)

EOF
    # Note: Dollar signs in the resume content (e.g., $5 M+) are literal and NOT escaped (e.g. \$)
    # because the here document delimiter 'EOF' is quoted, preventing shell expansion.

    if [ -f "$MARKDOWN_FILE" ]; then
        echo "Markdown file successfully created: ${MARKDOWN_FILE}"
    else
        echo "ERROR: Failed to create Markdown file: ${MARKDOWN_FILE}"
        exit 1
    fi
    echo

    # --- Generate DOCX ---
    echo "Generating DOCX resume: ${DOCX_FILE}..."
    if pandoc "$MARKDOWN_FILE" --standalone -o "$DOCX_FILE"; then
        echo "DOCX resume successfully created: ${DOCX_FILE}"
    else
        echo "ERROR: Failed to generate DOCX file. Please check Pandoc installation and messages above."
    fi
    echo

    # --- Generate PDF ---
    if [ "$has_pdflatex" = true ]; then
        echo "Generating PDF resume: ${PDF_FILE}..."
        # Added --variable geometry:margin=1in
        if pandoc "$MARKDOWN_FILE" -o "$PDF_FILE" --pdf-engine=pdflatex --variable geometry:margin=1in; then
            echo "PDF resume successfully created: ${PDF_FILE}"
        else
            echo "ERROR: Failed to generate PDF file. Please check LaTeX installation and Pandoc messages."
            echo "Common issues include missing LaTeX packages (e.g., for fonts, tables, specific unicode characters) or complex formatting."
            echo "If BasicTeX was installed, you might need to install additional packages via 'tlmgr'."
            echo "Example: sudo tlmgr install <package_name>"
            echo "You can try to diagnose by running Pandoc with --verbose flag, e.g.:"
            echo "pandoc \"${MARKDOWN_FILE}\" -o \"${PDF_FILE}\" --pdf-engine=pdflatex --variable geometry:margin=1in --verbose"
        fi
    else
        echo "Skipping PDF generation because pdflatex was not found or its installation was skipped/failed."
    fi
    echo

    echo "-----------------------------------------------------------------------"
    echo "Resume generation process finished."
    echo
    echo "FILES SUMMARY (in $(pwd) ):"
    if [ -f "$MARKDOWN_FILE" ]; then
        echo "  [CREATED] Markdown source: ./${MARKDOWN_FILE}"
    else
        echo "  [NOT CREATED] Markdown source: ./${MARKDOWN_FILE}"
    fi

    if [ -f "$DOCX_FILE" ]; then
        echo "  [CREATED] DOCX resume: ./${DOCX_FILE}"
    else
        echo "  [NOT CREATED or FAILED] DOCX resume: ./${DOCX_FILE}"
    fi

    if [ "$has_pdflatex" = true ]; then
        if [ -f "$PDF_FILE" ]; then
            echo "  [CREATED] PDF resume: ./${PDF_FILE}"
        else
            echo "  [NOT CREATED or FAILED] PDF resume: ./${PDF_FILE}"
        fi
    else
        echo "  [SKIPPED] PDF resume (pdflatex not found or not installed)"
    fi
    echo
    echo "You may want to delete the intermediate Markdown file (${MARKDOWN_FILE}) if it's no longer needed."
    echo "-----------------------------------------------------------------------"

    # Optional: Clean up the Markdown file
    # read -r -p "Do you want to delete the intermediate Markdown file (${MARKDOWN_FILE})? (y/N) " reply
    # echo
    # if [[ "$reply" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    #     if rm "$MARKDOWN_FILE"; then
    #         echo "Deleted ${MARKDOWN_FILE}."
    #     else
    #         echo "Failed to delete ${MARKDOWN_FILE}."
    #     fi
    # fi
}

# --- Script Execution ---
# Ensure main is called to execute the script logic
main
