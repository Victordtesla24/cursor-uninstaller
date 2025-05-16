### Prompt 1: Confirmation of Consolidation Strategy & Initial Cleanup Plan

**Cursor AI Assistant (You) Received User Confirmation on the following:**
*   **Canonical Dashboard**: `enhancedDashboard.jsx` is confirmed as the main dashboard component.
*   **API Layer**: `lib/enhancedDashboardApi.js` will be the consolidated API layer, using `mockApi.js` as a fallback.
*   **Styling**: Standardize on Tailwind CSS; `StyledJsx` will be removed.

**New Instructions for Cursor AI Assistant (You):**

"Proceed with Phase 1: Initial Consolidation and Cleanup.

**1.1. Consolidate Dashboard Entry Point & Main Component:**
    *   Merge any unique and essential functionalities, state management, and UI elements from `ui/dashboard/Dashboard.jsx` and `ui/dashboard/index.jsx` into `ui/dashboard/enhancedDashboard.jsx`. Prioritize the structure and API usage patterns already present in `enhancedDashboard.jsx`.
    *   Ensure that `ui/dashboard/enhancedDashboard.jsx` correctly handles all data fetching, state, and component integrations previously split among the three files.
    *   Update `ui/dashboard/main.jsx` to:
        *   Render only `EnhancedDashboard` as the primary application component.
        *   Remove imports for `Dashboard.jsx` or `index.jsx` if present.
        *   Ensure the MCP setup logic in `main.jsx` (`setupMcpIfNeeded`) correctly initializes the environment for `enhancedDashboardApi.js`. Clarify and streamline the initialization of `window.__MCP_CLIENT` and `window.PUPPETEER_MCP_AVAILABLE`, ensuring `lib/setupMcpServer.js` is the authority for this. The direct `fetch` calls to Puppeteer in `main.jsx`'s `__MCP_CLIENT` mock should be removed if `lib/setupMcpServer.js` and `lib/puppeteerClient.js` handle this.
    *   Document any significant merged logic with inline comments.
    *   After these changes, report back. I will then confirm the deletion of `ui/dashboard/Dashboard.jsx` and `ui/dashboard/index.jsx`.

**1.2. Consolidate API Layer:**
    *   Refactor `ui/dashboard/lib/enhancedDashboardApi.js`:
        *   Remove its internal `mockDashboardData`.
        *   Modify its data fetching and update operations (`refreshData`, `updateSelectedModel`, `updateSetting`, `updateTokenBudget`) to use `ui/dashboard/mockApi.js` as a fallback if MCP is unavailable (based on its `isMcpAvailable()` check which uses `safeCheckMcp`) or if a direct MCP operation fails.
        *   Ensure it uses a consistent method for MCP interaction (e.g., its internal `use_mcp_tool` and `access_mcp_resource` which should rely on a properly initialized `window.__MCP_CLIENT` from `lib/setupMcpServer.js` via `window.__MCP_INIT`, or `window.cline.callMcpFunction` if that's deemed more appropriate for `cline-dashboard` server interaction after further analysis). Resolve any conflicts between `window.__MCP_INIT` usage and `window.cline.callMcpFunction`.
    *   Update `ui/dashboard/enhancedDashboard.jsx` to exclusively use this refactored `lib/enhancedDashboardApi.js` for all its data operations.
    *   Document API interaction patterns.
    *   After these changes, report back. I will then confirm the deletion of `ui/dashboard/mcpApi.js` and `ui/dashboard/magic-mcp-integration.js`.

**1.3. Standardize Styling:**
    *   Ensure `ui/dashboard/enhancedDashboard.jsx` and all its child components exclusively use Tailwind CSS (via the existing `ui/dashboard/styles.css`) and an optional, minimal set of global styles if necessary in `styles.css`.
    *   If `StyledJsx` was used in `Dashboard.jsx` or `index.jsx` for specific component styles that were merged into `enhancedDashboard.jsx` or its children, migrate these styles to Tailwind utility classes or, if complex, to `styles.css`.
    *   Remove the `ui/dashboard/components/StyledJsx.jsx` component and all its usages.

**1.4. Standardize Component Imports:**
    *   Review `ui/dashboard/enhancedDashboard.jsx`'s direct component imports.
    *   Attempt to refactor to use the barrel file (`ui/dashboard/components/index.js`).
    *   If circular dependencies prevent this, thoroughly document the specific dependencies causing the issue as a comment in `enhancedDashboard.jsx` near the import block.

**1.5. Configuration File Cleanup:**
    *   Examine `ui/dashboard/.babelrc` and `ui/dashboard/babel.config.js`. If `.babelrc` is redundant or its configuration can be merged into `babel.config.js`, propose changes to consolidate into `babel.config.js`.
    *   Review `ui/dashboard/jsconfig.json` and `ui/dashboard/tsconfig.json`. Given the presence of `.d.ts` files and TypeScript-related devDependencies (`@types/...` if they were there, though not explicitly listed in `package.json`'s devDeps, `tsconfig.json` implies TS intentions), clarify if the primary development language is intended to be TypeScript. If so, ensure `tsconfig.json` is comprehensive and `jsconfig.json` is removed if it's redundant.

**General Instructions for this Phase:**
*   Adhere strictly to `my-directory-management-protocols.mdc` (no new files if existing can be modified, confirm deletions) and `my-error-fixing-protocols.mdc`.
*   Focus on minimal diffs for each change.
*   Update `ui/dashboard/Current-Tasks.md` to reflect the completion of sub-tasks under Phase 1.
*   Provide updated code blocks for all changed files.

-------

### Prompt 2: UI/UX Enhancement - Detailed Plan & Initial Implementation

**Cursor AI Assistant (You) has completed Phase 1 (Consolidation) and received user confirmation for file deletions.**

**New Instructions for Cursor AI Assistant (You):**

"Proceed with Phase 2: UI/UX Enhancement.

**2.1. Develop Detailed UI/UX Enhancement Plan:**
    *   Based on the consolidated `enhancedDashboard.jsx` and its components in `ui/dashboard/components/`, propose specific UI/UX enhancements for each panel (`MetricsPanel`, `TokenUtilization`, `CostTracker`, `UsageStats` (or `UsageChart`), `ModelSelector`, `SettingsPanel`) and the main `EnhancedHeader` (or its equivalent in `enhancedDashboard.jsx`).
    *   Detail how Shadcn UI components (e.g., `Card`, `Button`, `Input`, `Switch`, `Tooltip`, `Progress`, `Accordion`, `Collapsible` as re-exported in `ui/dashboard/components/index.js`) and `lucide-react` icons will be incorporated into each.
    *   Describe layout adjustments using Tailwind CSS for improved visual hierarchy, spacing, and responsiveness. Reference key classes from `ui/dashboard/styles.css` or `lib/config.js` (themeConfig) if applicable.
    *   For `UsageChart.jsx` (or `UsageStats.jsx` if it handles charting): Evaluate the current charting solution. If it's custom via `StyledJsx` (now removed/migrated), propose using `chart.js` (from `package.json`) for cleaner, more maintainable charts, or detail how the existing solution will be enhanced.
    *   Present this plan. No code changes yet for this sub-task.

**2.2. Implement Header and Main Layout Enhancements:**
    *   Begin by refactoring the main layout of `enhancedDashboard.jsx` and its primary header section.
    *   Implement the `AnimatedTabs` or a similar modern tab navigation for `Overview`, `Usage Statistics`, `Settings`.
    *   Incorporate `StatusBadge` for connection status display.
    *   Use Tailwind CSS for layout and styling.
    *   Ensure responsiveness.
    *   Provide updated code for `enhancedDashboard.jsx` and relevant parts of `styles.css`.

-------

### Prompt 3: UI/UX Enhancement - Component-by-Component Implementation

**Cursor AI Assistant (You) has completed Task 2.1 (UI/UX Plan) and 2.2 (Header/Layout) and received user approval for the plan.**

**New Instructions for Cursor AI Assistant (You):**

"Implement the approved UI/UX enhancements for the dashboard panels, one panel at a time. For each panel:
    1.  Refactor its JSX structure to use appropriate Shadcn UI components (Cards, Buttons, etc.) and `lucide-react` icons.
    2.  Apply Tailwind CSS for styling and responsiveness.
    3.  Ensure data is correctly passed and displayed.
    4.  Maintain existing functionality unless the approved plan specifies a change.
    5.  Adhere to minimal diffs.
    6.  Provide the updated code for the component's `.jsx` file.

Start with `ui/dashboard/components/MetricsPanel.jsx`."

**(User gives go-ahead for each subsequent panel after reviewing the previous one, e.g., "Proceed with TokenUtilization.jsx", then "Proceed with CostTracker.jsx", and so on for `UsageStats.jsx` (or `UsageChart.jsx`), `ModelSelector.jsx`, and `SettingsPanel.jsx`.)**

-------

### Prompt 4: Test Suite Update - Plan & Implementation

**Cursor AI Assistant (You) has completed all UI/UX enhancements in Phase 2.**

**New Instructions for Cursor AI Assistant (You):**

"Proceed with Phase 3: Test Suite Update and Error Resolution.

**4.1. Review and Plan Test Suite Updates:**
    *   Thoroughly review all test files in `ui/dashboard/tests/`.
    *   Identify and list:
        *   Redundant tests (e.g., multiple test files for `EnhancedDashboard`).
        *   Tests for already deleted components (`Dashboard.jsx`, `index.jsx`).
        *   Components with low or missing test coverage.
        *   Tests that rely heavily on mocking child components instead of testing integration.
    *   Propose a plan to:
        *   Consolidate tests for `EnhancedDashboard.jsx` into one primary test file (e.g., `enhancedDashboard.test.jsx`).
        *   Update tests for each refactored component in `ui/dashboard/components/` to reflect UI changes and ensure they cover rendering with various props, user interactions, data display, and error/loading states.
        *   Write new tests for any newly introduced logic or UI elements.
        *   Specify how API calls (to the consolidated `lib/enhancedDashboardApi.js`) will be mocked for component tests (e.g., mocking the module or specific functions to return different states like success, error, loading).
    *   Present this plan.

**4.2. Implement Test Suite Updates:**
    *   Execute the approved test plan.
    *   Remove tests for deleted components.
    *   Refactor and write tests, ensuring they are deterministic and follow the 'no mocking of internal logic' principle.
    *   Ensure all tests pass (`npm test`).
    *   Provide updated code for all changed test files and list any new test files created.
    *   Report the final test coverage if available.

-------

### Prompt 5: Final Review, Documentation, and Completion Check

**Cursor AI Assistant (You) has completed Test Suite Updates, and all tests are passing.**

**New Instructions for Cursor AI Assistant (You):**

"Perform the final review and prepare for completion.

**5.1. Inline Documentation:**
    *   Review all modified `.jsx` files in `ui/dashboard/` and its subdirectories.
    *   Add inline comments to explain any non-obvious logic, complex state management, or significant architectural decisions made during the refactoring.

**5.2. Update Task Tracker:**
    *   Ensure `ui/dashboard/Current-Tasks.md` is fully up-to-date, with all tasks marked as complete, including sub-tasks for documentation and validation.

**5.3. Validation Checks:**
    *   Confirm no directory structure violations according to `my-directory-management-protocols.mdc`.
    *   Confirm no duplicate files were created.
    *   (Simulate) Run linters/scanners if available to verify these.

**5.4. Final Report:**
    *   Provide a summary of all major changes implemented.
    *   Confirm all deliverables from the original brief have been met.
    *   State that all tasks are complete, all tests pass, and the dashboard is ready according to the completion criteria.

-------
