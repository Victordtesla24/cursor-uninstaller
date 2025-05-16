/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./ui/**/*.{js,jsx,ts,tsx}",
    "./components/**/*.{js,jsx,ts,tsx}"
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: "#4a6cf7",
          light: "#eef1fe"
        },
        background: "#ffffff",
        "background-secondary": "#f9f9f9",
        foreground: "#1a1a1a",
        card: {
          DEFAULT: "#ffffff",
          foreground: "#1a1a1a",
        },
        muted: {
          DEFAULT: "#f1f5f9",
          foreground: "#64748b",
        },
        accent: {
          DEFAULT: "#eef1fe",
          foreground: "#4a6cf7",
        },
        destructive: {
          DEFAULT: "#ef4444",
          foreground: "#ffffff",
        },
        border: "#e2e8f0",
        input: "#e2e8f0",
        ring: "#4a6cf7",
        success: {
          DEFAULT: "#10b981",
          foreground: "#ffffff"
        },
        warning: {
          DEFAULT: "#f59e0b",
          foreground: "#ffffff"
        },
        error: {
          DEFAULT: "#ef4444",
          foreground: "#ffffff"
        }
      },
      borderRadius: {
        md: "0.375rem",
        sm: "0.25rem",
        lg: "0.5rem",
      },
      boxShadow: {
        sm: "0 1px 2px 0 rgba(0, 0, 0, 0.05)",
        md: "0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)",
      },
    },
  },
  plugins: [],
}
