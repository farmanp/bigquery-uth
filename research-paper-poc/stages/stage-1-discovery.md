# Stage 1: Problem Discovery

**Duration:** 1-2 hours  
**Started:** [Date/Time]  
**Completed:** [Date/Time]  
**Status:** [Not Started / In Progress / Complete]

## Objective
Perform rapid feasibility assessment and make informed go/no-go decision before investing significant time in implementation.

## Entry Criteria Checklist
- [ ] Research paper identified and accessible
- [ ] Project context document completed
- [ ] High-level understanding of paper's domain
- [ ] Basic development environment available
- [ ] Time allocated for POC project (1-3 weeks)

## AI Collaboration Setup

### AI Persona: Research Analyst
**Role:** Senior research engineer with expertise in [DOMAIN from project context]
**Collaboration Level:** High autonomy analysis with human validation
**Primary Tools:** ChatGPT/Claude for analysis, human for domain expertise validation

## Stage Tasks

### Task 1: Initial Paper Analysis
**Objective:** Extract key technical information and assess algorithm clarity

#### AI Prompt Template
```markdown
**Role:** You are a senior research engineer with expertise in [INSERT_DOMAIN].

**Context:** I want to implement a proof-of-concept based on this research paper:
- Title: [INSERT_PAPER_TITLE]
- Authors: [INSERT_AUTHORS]
- Venue: [INSERT_VENUE]

**Paper Summary:** 
[COPY_PASTE_ABSTRACT_AND_KEY_SECTIONS]

**Task:** Perform a comprehensive feasibility analysis for implementing this paper as a POC.

**Analysis Framework:**
1. **Algorithm Clarity:** How well-described is the core algorithm?
2. **Data Requirements:** What datasets are needed and are they accessible?
3. **Computational Complexity:** What are the resource requirements?
4. **Dependencies:** What libraries, frameworks, or tools are required?
5. **Reproducibility:** How much implementation guidance is provided?

**Output Format:**
- **Core Algorithm Summary:** [2-3 sentences describing the main contribution]
- **Implementation Complexity:** [Simple/Medium/Complex with reasoning]
- **Data Assessment:** [Available/Adaptable/Problematic with details]
- **Resource Requirements:** [Computational needs and constraints]
- **Reproducibility Score:** [High/Medium/Low with justification]
- **Recommendation:** [Go/No-Go with confidence level]
- **Implementation Roadmap:** [If Go: high-level approach and timeline]

**Success Criteria:**
- Clear go/no-go recommendation with reasoning
- Realistic timeline estimate (days/weeks)
- Identification of major risks and mitigation strategies
```

#### AI Response Capture
**AI Analysis Results:**
```
[PASTE AI RESPONSE HERE]
```

#### Human Validation
**Domain Expertise Check:**
- [ ] AI analysis aligns with my understanding of the field
- [ ] Technical complexity assessment seems realistic
- [ ] Resource requirements match my available capacity
- [ ] Identified risks are reasonable and addressable

**Corrections/Additions:**
[Note any disagreements with AI analysis or additional considerations]

### Task 2: Deep Algorithm Analysis
**Objective:** Break down algorithm into implementable components

#### AI Prompt Template
```markdown
**Context:** Based on your initial analysis, dive deeper into the algorithm implementation for [PAPER_TITLE].

**Specific Focus:** 
- Break down the algorithm into implementable components
- Identify the most challenging implementation aspects
- Suggest simplifications that preserve core concepts
- Recommend validation approaches

**Algorithm Details:**
[PASTE_RELEVANT_ALGORITHM_SECTIONS_FROM_PAPER]

**Output:** Step-by-step implementation strategy with complexity assessment for each component.

**Format:**
1. **Component Breakdown:** [List major algorithmic pieces]
2. **Implementation Challenges:** [Specific technical difficulties]
3. **Simplification Options:** [Ways to reduce complexity while preserving core ideas]
4. **Validation Strategy:** [How to verify each component works correctly]
5. **Implementation Order:** [Logical sequence for building components]
```

#### AI Response Capture
**Algorithm Breakdown:**
```
[PASTE AI RESPONSE HERE]
```

#### Component Analysis
**Core Components Identified:**
1. [Component 1: Description and complexity assessment]
2. [Component 2: Description and complexity assessment]
3. [Component 3: Description and complexity assessment]

**Highest Risk Components:**
- [Component]: [Why it's risky and potential mitigation]
- [Component]: [Why it's risky and potential mitigation]

### Task 3: Data Landscape Assessment
**Objective:** Evaluate data availability and requirements

#### AI Prompt Template
```markdown
**Context:** Analyzing data requirements for implementing [PAPER_TITLE].

**Paper Data Information:**
- Primary Dataset: [DATASET_NAME_FROM_PAPER]
- Data Characteristics: [SIZE_FORMAT_DESCRIPTION]
- Availability: [PUBLIC_PRIVATE_PROPRIETARY]

**Analysis Needed:**
1. **Data Availability:** Can I access the exact dataset used in the paper?
2. **Alternative Datasets:** What substitute datasets could work?
3. **Synthetic Data:** Could I generate representative synthetic data?
4. **Preprocessing Requirements:** What data transformations are needed?
5. **Data Challenges:** What data-related implementation issues might arise?

**Output Format:**
- **Primary Data Assessment:** [Availability and access method]
- **Alternative Options:** [Substitute datasets with pros/cons]
- **Synthetic Data Feasibility:** [Can generate and how]
- **Preprocessing Complexity:** [Required transformations and difficulty]
- **Data Risks:** [Potential data-related blockers]
```

#### AI Response Capture
**Data Analysis:**
```
[PASTE AI RESPONSE HERE]
```

#### Data Strategy Decision
**Chosen Data Approach:**
- [ ] Use exact dataset from paper
- [ ] Use alternative dataset: [DATASET_NAME]
- [ ] Generate synthetic data: [APPROACH]
- [ ] Combination approach: [DESCRIPTION]

**Rationale:** [Why this approach was chosen]

### Task 4: Technical Dependency Mapping
**Objective:** Identify required tools, libraries, and technical dependencies

#### AI Prompt Template
```markdown
**Context:** Mapping technical dependencies for [PAPER_TITLE] implementation.

**Implementation Context:**
- Primary Language: [PREFERRED_LANGUAGE]
- Development Environment: [LOCAL_CLOUD_HYBRID]
- Available Resources: [COMPUTATIONAL_CONSTRAINTS]

**Analysis Needed:**
1. **Required Libraries:** What frameworks and libraries are needed?
2. **Version Compatibility:** Any specific version requirements or conflicts?
3. **Installation Complexity:** How difficult is environment setup?
4. **Alternative Tools:** What alternatives exist if preferred tools unavailable?
5. **Dependency Risks:** What could go wrong with the technical stack?

**Output Format:**
- **Core Dependencies:** [Essential libraries with versions]
- **Optional Dependencies:** [Nice-to-have additions]
- **Installation Plan:** [Setup steps and complexity assessment]
- **Alternative Stacks:** [Backup technology choices]
- **Technical Risks:** [Dependency-related potential issues]
```

#### AI Response Capture
**Dependency Analysis:**
```
[PASTE AI RESPONSE HERE]
```

#### Technology Stack Decision
**Chosen Stack:**
- **Language:** [PROGRAMMING_LANGUAGE]
- **ML Framework:** [TENSORFLOW_PYTORCH_SKLEARN_ETC]
- **Data Processing:** [PANDAS_NUMPY_SPECIALIZED_TOOLS]
- **Visualization:** [MATPLOTLIB_PLOTLY_CUSTOM]
- **Development:** [IDE_VERSION_CONTROL_ENVIRONMENT]

**Installation Plan:**
1. [Step 1: Environment setup]
2. [Step 2: Core dependencies]
3. [Step 3: Optional tools]
4. [Step 4: Validation]

### Task 5: Risk Assessment and Mitigation
**Objective:** Identify major risks and develop mitigation strategies

#### AI Prompt Template
```markdown
**Context:** Risk assessment for [PAPER_TITLE] POC implementation.

**Current Assessment:**
- Algorithm Complexity: [SIMPLE_MEDIUM_COMPLEX]
- Data Availability: [AVAILABLE_ADAPTABLE_PROBLEMATIC]
- Resource Requirements: [WITHIN_LIMITS_CHALLENGING_EXCESSIVE]
- Technical Dependencies: [STRAIGHTFORWARD_MODERATE_COMPLEX]

**Risk Analysis Needed:**
1. **Technical Risks:** Algorithm complexity, data issues, performance problems
2. **Resource Risks:** Computational requirements, time constraints
3. **Knowledge Risks:** Domain expertise gaps, unclear specifications
4. **External Risks:** Dependency issues, data access problems

**Output Format:**
For each risk category, provide:
- **Risk Description:** [What could go wrong]
- **Likelihood:** [High/Medium/Low]
- **Impact:** [High/Medium/Low]
- **Mitigation Strategy:** [Specific actions to reduce risk]
- **Contingency Plan:** [What to do if risk materializes]
```

#### AI Response Capture
**Risk Analysis:**
```
[PASTE AI RESPONSE HERE]
```

#### Risk Prioritization
**High Priority Risks:** (High likelihood OR high impact)
1. **Risk:** [Description]
   - **Mitigation:** [Strategy]
   - **Contingency:** [Backup plan]

2. **Risk:** [Description]
   - **Mitigation:** [Strategy]
   - **Contingency:** [Backup plan]

**Medium Priority Risks:**
1. **Risk:** [Description] - **Mitigation:** [Strategy]
2. **Risk:** [Description] - **Mitigation:** [Strategy]

## Go/No-Go Decision Framework

### Decision Criteria Assessment
**✅ GREEN LIGHT Criteria:**
- [ ] Core algorithm is clearly described with mathematical formulation
- [ ] Required datasets are publicly available or can be synthesized
- [ ] Computational requirements are reasonable for available resources
- [ ] Dependencies are available and compatible
- [ ] High confidence in successful implementation within timeline

**🟡 YELLOW LIGHT Criteria:**
- [ ] Algorithm description mostly clear but some details missing
- [ ] Datasets need adaptation or synthetic generation
- [ ] Moderate computational requirements (might need cloud resources)
- [ ] Some dependencies require learning or setup effort
- [ ] Reasonable confidence with some modifications to scope

**🔴 RED LIGHT Criteria:**
- [ ] Algorithm description too vague or incomplete
- [ ] Requires proprietary datasets or models not available
- [ ] Computational requirements exceed available resources
- [ ] Needs specialized hardware not accessible
- [ ] Low confidence in successful implementation

### Decision Summary
**Overall Assessment:** [GREEN / YELLOW / RED]

**Decision:** [GO / NO-GO / CONDITIONAL GO]

**Confidence Level:** [High / Medium / Low]

**Reasoning:**
[Detailed explanation of decision rationale based on analysis]

### If GO: Implementation Strategy
**Approach:** [High-level implementation plan]

**Timeline:** [Realistic duration estimate]
- Stage 2 (Investigation): [Duration]
- Stage 3 (Specification): [Duration]
- Stage 4 (Planning): [Duration]
- Stage 5 (Implementation): [Duration]

**Key Milestones:**
1. [Milestone 1: Description and target date]
2. [Milestone 2: Description and target date]
3. [Milestone 3: Description and target date]

**Success Criteria:**
- [Criterion 1: Specific measurable outcome]
- [Criterion 2: Specific measurable outcome]
- [Criterion 3: Specific measurable outcome]

**Minimum Viable Implementation:**
[Simplest version that still proves the core concept]

### If NO-GO: Alternative Actions
**Reasons for No-Go:**
[Primary factors that led to negative decision]

**Alternative Options:**
- [ ] Choose different paper with similar learning objectives
- [ ] Modify scope to focus on specific components only
- [ ] Defer implementation until resources/knowledge available
- [ ] Pivot to related but more feasible approach

## Stage Completion

### Deliverables Checklist
- [ ] **Feasibility Assessment:** Complete analysis with clear recommendation
- [ ] **Technical Roadmap:** If GO, high-level implementation plan
- [ ] **Risk Assessment:** Major risks identified with mitigation strategies
- [ ] **Success Criteria:** Clear definition of POC success
- [ ] **Decision Documentation:** Rationale for go/no-go decision

### Quality Validation
**AI Analysis Quality:**
- [ ] Algorithm analysis is technically accurate
- [ ] Data assessment covers all practical considerations
- [ ] Dependency analysis is complete and realistic
- [ ] Risk assessment identifies major potential issues
- [ ] Timeline estimates account for learning curve and debugging

**Human Review:**
- [ ] Decision aligns with personal learning objectives
- [ ] Resource estimates match available capacity
- [ ] Risk tolerance is appropriate for project goals
- [ ] Success criteria align with intended outcomes

### Next Steps
**If GO:**
- [ ] Proceed to Stage 2: Spike/Investigation
- [ ] Update project context with decision rationale
- [ ] Set up development environment
- [ ] Begin architecture design and experimentation

**If NO-GO:**
- [ ] Document lessons learned from analysis
- [ ] Consider alternative papers or approaches
- [ ] Update project context with decision rationale
- [ ] Plan next steps for continued learning

### Lessons Learned
**Key Insights from Analysis:**
[Important discoveries about the paper, domain, or implementation approach]

**Process Improvements:**
[Notes on how to improve the discovery stage for future projects]

---

## Notes and Observations
[Space for additional thoughts, concerns, or ideas that emerged during the analysis]

---

*This stage should take 1-2 hours maximum. The goal is rapid triage, not perfect analysis. Trust the structured approach and move forward with the decision once criteria are assessed.*