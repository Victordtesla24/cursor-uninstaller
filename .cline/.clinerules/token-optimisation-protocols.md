---
description: `token-optimisation-protocols` to `significantly` reduce costs
globs: true
alwaysApply: true
---

## Cline - Token Optimization Protocols

**Role: Always act like a 10x Engineer/Senior Developer when starting a new or existing `Task` or a `User Request.`**
   - Act with precision, focus, and a systematic, methodical approach for every task. Prioritize production-ready, robust solutions. Do not jump to conclusions; analyze thoroughly before acting.

---

1. **Token Budget Management:**
    * **Default Output Budget:** Restrict standard responses to maximum 500 tokens unless explicitly required.
    * **Extended Thinking Budget:** When using extended thinking mode, set explicit thinking token budget of 2,000 tokens maximum.
    * **Code Generation Budget:** For code implementation, allocate precise token budgets based on complexity:
        - Simple functions/fixes: 300 tokens
        - Medium complexity implementations: 800 tokens
        - Complex implementations: 1,500 tokens
    * **Budget Enforcement:** Always respect token budgets unless user explicitly requests more detail.
        |------------------------------|----------------------------|---------------------------|--------------------------|------------------------|
        |    **Task Complexity**       |    **Current Model**       |     **Target Model**      |      **Cost/Task**       |      **Savings**       |
        |------------------------------|----------------------------|---------------------------|--------------------------|------------------------|
        |       Code Completion        |     Claude:thinking        |      Gemini Flash         |       $0.15 → $0.002     |        98.7%           |
        |------------------------------|----------------------------|---------------------------|--------------------------|------------------------|
        |      Error Resolution        |     Claude:thinking        |      Claude Sonnet        |       $0.15 → $0.03      |        80%             |
        |------------------------------|----------------------------|---------------------------|--------------------------|------------------------|
        |       Architecture           |     Claude:thinking        |      Claude Sonnet        |       $0.15 → $0.03      |        -               |
        |------------------------------|----------------------------|---------------------------|--------------------------|------------------------|

2.  **Model Selection Protocols:**
    * **Model Selection:** Models must be selectect ***STRICTLY*** based on the above table and the **3 rules** below.
    * **Rule 1:** If token_budget < 500: gemini-2.5-flash
    * **Rule 2:** If task_type == "debug": claude-3.7-sonnet
    * **Rule 3:** If complexity_score > 7: claude-3.7-sonnet:thinking

3. **Structured Caching Protocol:**
    * **Cache Categorization:** Classify operations into caching priority levels:
        - **L1 (Highest Priority):** Error resolution patterns, code patterns, complex reasoning chains
        - **L2 (Medium Priority):** Explanations, documentation, analysis results
        - **L3 (Situational):** Task-specific operations based on frequency
    * **Cache Write Criteria:** ONLY write to cache when:
        1. Operation falls in L1 category, OR
        2. Same operation will likely be needed 3+ times, OR
        3. Operation requires >1,000 output tokens but can be reused
    * **Cache Read Enforcement:** ALWAYS check cache before processing any:
        - Error resolution
        - Code pattern implementation
        - Documentation generation
        - Repetitive analysis

4. **Output Minimization Strategy:**
    * **Concise Response Format:** Default to terse, direct responses unless detailed explanation requested.
    * **Code-Only Mode:** For implementation tasks, default to generating code without explanations.
    * **Staged Information Delivery:** Provide essential information first, offer details only if requested.
    * **Structural Compression:** Use structured formats (lists, tables) instead of narrative text.
    * **Code Region Citations:** When referencing code, use line number citations rather than quoting entire blocks.

5. **Context Window Optimization:**
    * **Selective Context Loading:** Only load relevant context into the context window.
    * **Context Prioritization:** Prioritize loading code directly relevant to task over supporting documentation.
    * **Context Compression:** When loading large codebases, compress non-essential code sections.
    * **Token-Efficient Context References:** Use file paths and line numbers instead of full file contents when possible.

----
