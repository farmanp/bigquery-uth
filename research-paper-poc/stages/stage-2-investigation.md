# Stage 2: Spike/Investigation

**Duration:** 2-8 hours  
**Started:** [Date/Time]  
**Completed:** [Date/Time]  
**Status:** [Not Started / In Progress / Complete]

## Objective
Design system architecture and validate critical assumptions through targeted experiments before full implementation.

## Entry Criteria Checklist
- [ ] Stage 1 completed with GO decision
- [ ] Feasibility assessment and technical roadmap available
- [ ] Development environment set up and tested
- [ ] Key risks and unknowns identified from Stage 1

## AI Collaboration Setup

### AI Persona: Technical Investigator
**Role:** Technical architect specializing in [DOMAIN] with deep implementation experience
**Collaboration Level:** Medium autonomy research with human architectural validation
**Primary Tools:** ChatGPT/Claude for architecture design, coding tools for prototyping

## Investigation Goals

### Primary Objectives
- [ ] Design system architecture that balances simplicity with functionality
- [ ] Validate critical technical assumptions through targeted experiments
- [ ] Create implementation plan that minimizes identified risks
- [ ] Establish success metrics and validation approaches

### Key Questions to Answer
1. **Architecture:** How should components be structured and integrated?
2. **Data Pipeline:** What is the end-to-end data flow and processing approach?
3. **Algorithm Implementation:** What are the critical implementation details and potential pitfalls?
4. **Validation Strategy:** How will we verify the implementation works correctly?

## Stage Tasks

### Task 1: System Architecture Design
**Objective:** Create overall system design with clear component boundaries

#### AI Prompt Template
```markdown
**Role:** You are a technical architect specializing in [INSERT_DOMAIN] with deep implementation experience.

**Context:** 
- Paper: [INSERT_PAPER_TITLE]
- Go decision made based on: [COPY_FROM_STAGE_1_DECISION_SUMMARY]
- Key risks identified: [COPY_TOP_3_RISKS_FROM_STAGE_1]
- Available resources: [COMPUTATIONAL_RESOURCES], [TIME_BUDGET]

**Architecture Design Goals:**
1. Design system architecture that balances simplicity with functionality
2. Create modular design with clear component boundaries
3. Plan component interactions that minimize coupling
4. Establish data flow that enables testing and validation

**System Requirements:**
- **Modularity:** Components should be independently testable
- **Simplicity:** Architecture should be understandable and maintainable
- **Extensibility:** Design should allow for future improvements
- **Testability:** Each component should be validatable in isolation

**Output Requirements:**
- System architecture diagram (text/ASCII representation)
- Component responsibility definitions
- Interface specifications between components
- Data flow design with transformation points
- Error handling and logging strategy

**Format:**
```
## System Architecture Overview
[High-level description of architectural approach]

## Component Breakdown
### Component 1: [Name]
- Responsibility: [What it does]
- Inputs: [Data/parameters it receives]
- Outputs: [Data/results it produces]
- Dependencies: [What it relies on]

### Component 2: [Name]
[Same format as above]

## Data Flow Design
[Step-by-step description of data movement through system]

## Interface Specifications
[How components communicate with each other]

## Error Handling Strategy
[How system handles and recovers from failures]
```
```

#### AI Response Capture
**Architecture Design:**
```
[PASTE AI RESPONSE HERE]
```

#### Human Architecture Review
**Architecture Assessment:**
- [ ] Design is modular and testable
- [ ] Component responsibilities are clear and single-purpose
- [ ] Interfaces between components are well-defined
- [ ] Data flow is logical and efficient
- [ ] Error handling covers major failure modes
- [ ] Architecture matches available time/skill constraints

**Modifications Needed:**
[Note any changes to the AI-proposed architecture]

**Final Architecture Decision:**
[Confirm the architecture approach to be used]

### Task 2: Data Pipeline Design
**Objective:** Design end-to-end data processing pipeline

#### AI Prompt Template
```markdown
**Focus:** Design the end-to-end data processing pipeline for [PAPER_TITLE].

**Data Context:**
- Primary Data: [DATA_SOURCE_FROM_STAGE_1]
- Data Format: [INPUT_FORMAT_AND_STRUCTURE]
- Processing Requirements: [TRANSFORMATIONS_NEEDED]
- Output Requirements: [ALGORITHM_INPUT_FORMAT]

**Pipeline Design Requirements:**
- Input data ingestion and validation
- Preprocessing and feature extraction
- Algorithm input preparation
- Output processing and visualization
- Error handling for data quality issues
- Performance considerations for data volume

**Output Format:**
```
## Data Pipeline Architecture
[Overview of pipeline stages and flow]

## Stage 1: Data Ingestion
- Input: [Data sources and formats]
- Processing: [Loading and initial validation]
- Output: [Raw data in standard format]
- Error Handling: [Invalid data, missing files, etc.]

## Stage 2: Preprocessing
- Input: [Raw data from ingestion]
- Processing: [Cleaning, normalization, transformation]
- Output: [Cleaned data ready for feature extraction]
- Error Handling: [Data quality issues, missing values]

## Stage 3: Feature Extraction
- Input: [Preprocessed data]
- Processing: [Feature computation and selection]
- Output: [Features ready for algorithm]
- Error Handling: [Feature computation failures]

## Stage 4: Algorithm Input Preparation
- Input: [Extracted features]
- Processing: [Final formatting for algorithm]
- Output: [Algorithm-ready data]
- Error Handling: [Format validation, dimension checks]

## Performance Considerations
[Memory usage, processing time, scalability]

## Quality Validation
[Data quality checks at each stage]
```
```

#### AI Response Capture
**Data Pipeline Design:**
```
[PASTE AI RESPONSE HERE]
```

#### Pipeline Validation Experiment
**Experiment Objective:** Validate data pipeline design with sample data

**Experiment Steps:**
1. [ ] Acquire small sample of representative data
2. [ ] Implement basic version of each pipeline stage
3. [ ] Test end-to-end data flow
4. [ ] Validate output format matches algorithm requirements
5. [ ] Test error handling with problematic data

**Implementation Notes:**
```python
# Basic pipeline implementation for testing
# [WRITE SIMPLE CODE TO TEST PIPELINE CONCEPTS]
```

**Experiment Results:**
- **Data Loading:** [Success/Issues encountered]
- **Preprocessing:** [Success/Issues encountered]
- **Feature Extraction:** [Success/Issues encountered]
- **Format Validation:** [Success/Issues encountered]
- **Error Handling:** [Success/Issues encountered]

**Pipeline Refinements:**
[Changes needed based on experiment results]

### Task 3: Algorithm Implementation Strategy
**Objective:** Design approach for implementing the core algorithm

#### AI Prompt Template
```markdown
**Focus:** Design implementation strategy for the core algorithm from [PAPER_TITLE].

**Algorithm Context:**
- Core Algorithm: [ALGORITHM_DESCRIPTION_FROM_PAPER]
- Key Components: [MAJOR_ALGORITHMIC_PIECES]
- Mathematical Foundations: [KEY_EQUATIONS_OR_CONCEPTS]
- Implementation Challenges: [KNOWN_DIFFICULTIES_FROM_STAGE_1]

**Implementation Strategy Requirements:**
- Break algorithm into implementable functions
- Define data structures for internal representations
- Plan optimization strategies for performance
- Design validation approach for correctness
- Account for numerical stability and edge cases

**Output Format:**
```
## Algorithm Implementation Plan
[High-level approach to implementing the algorithm]

## Component Implementation Strategy
### Component 1: [Name]
- Mathematical Foundation: [Key equations/concepts]
- Implementation Approach: [How to code this component]
- Data Structures: [Internal representations needed]
- Validation Method: [How to test correctness]
- Performance Considerations: [Optimization opportunities]

### Component 2: [Name]
[Same format as above]

## Integration Strategy
[How components work together]

## Validation Approach
[How to verify algorithm correctness]
- Unit Tests: [Test individual components]
- Integration Tests: [Test component interactions]
- End-to-End Tests: [Test complete algorithm]
- Performance Tests: [Validate speed/memory requirements]

## Risk Mitigation
[Specific approaches to handle implementation challenges]
```
```

#### AI Response Capture
**Algorithm Implementation Strategy:**
```
[PASTE AI RESPONSE HERE]
```

#### Algorithm Prototype Experiment
**Experiment Objective:** Validate core algorithm implementation approach

**Prototype Scope:**
- [ ] Implement simplified version of most critical algorithm component
- [ ] Test with known input/output examples
- [ ] Validate mathematical correctness
- [ ] Assess implementation complexity

**Implementation Notes:**
```python
# Core algorithm prototype
# [WRITE SIMPLIFIED VERSION OF KEY ALGORITHM COMPONENT]
```

**Prototype Results:**
- **Mathematical Correctness:** [Verified against known examples]
- **Implementation Complexity:** [Easier/harder than expected]
- **Performance Characteristics:** [Speed/memory observations]
- **Edge Cases:** [Potential issues discovered]

**Implementation Refinements:**
[Changes to approach based on prototype results]

### Task 4: Integration and Validation Strategy
**Objective:** Plan how components integrate and how to validate the complete system

#### AI Prompt Template
```markdown
**Focus:** Design integration and validation strategy for [PAPER_TITLE] POC.

**Integration Context:**
- System Components: [LIST_FROM_ARCHITECTURE_DESIGN]
- Component Interfaces: [HOW_COMPONENTS_COMMUNICATE]
- Data Flow: [END_TO_END_DATA_MOVEMENT]
- Success Criteria: [FROM_PROJECT_CONTEXT]

**Integration Planning Requirements:**
- Component integration patterns and sequencing
- End-to-end system validation approach
- Performance monitoring and debugging capabilities
- Deployment and execution workflow
- Documentation and demonstration preparation

**Output Format:**
```
## Integration Strategy
[How to combine components into working system]

## Component Integration Plan
### Integration Phase 1: [Description]
- Components: [Which components to integrate]
- Integration Points: [Specific interfaces to connect]
- Testing Approach: [How to validate integration]
- Success Criteria: [What indicates successful integration]

### Integration Phase 2: [Description]
[Same format as above]

## System Validation Plan
### Functional Validation
- Core Functionality: [Test primary algorithm operation]
- Data Processing: [Validate data pipeline correctness]
- Error Handling: [Test failure scenarios]
- Performance: [Verify speed/memory requirements]

### Quality Validation
- Code Quality: [Testing, documentation, maintainability]
- Result Quality: [Accuracy, consistency, interpretability]
- User Experience: [Ease of setup and use]

## Monitoring and Debugging
[How to observe system behavior and diagnose issues]

## Demonstration Plan
[How to present and explain the working POC]
```
```

#### AI Response Capture
**Integration and Validation Strategy:**
```
[PASTE AI RESPONSE HERE]
```

#### Integration Experiment
**Experiment Objective:** Test integration feasibility with minimal components

**Integration Test:**
1. [ ] Create minimal version of each major component
2. [ ] Implement basic interfaces between components
3. [ ] Test end-to-end data flow with sample data
4. [ ] Validate component communication works correctly

**Implementation Notes:**
```python
# Basic integration test
# [WRITE MINIMAL CODE TO TEST COMPONENT INTEGRATION]
```

**Integration Results:**
- **Component Communication:** [Success/Issues with interfaces]
- **Data Flow:** [End-to-end processing works/problems]
- **Error Propagation:** [How errors move through system]
- **Performance Impact:** [Integration overhead observations]

**Integration Refinements:**
[Changes needed based on integration experiment]

### Task 5: Risk Mitigation Planning
**Objective:** Develop specific strategies to address major risks identified in Stage 1

#### Risk Mitigation Review
**High Priority Risks from Stage 1:**
1. **Risk:** [COPY_FROM_STAGE_1]
   - **Investigation Results:** [What experiments revealed about this risk]
   - **Mitigation Strategy:** [Specific approach to reduce risk]
   - **Validation Method:** [How to test if mitigation works]

2. **Risk:** [COPY_FROM_STAGE_1]
   - **Investigation Results:** [What experiments revealed about this risk]
   - **Mitigation Strategy:** [Specific approach to reduce risk]
   - **Validation Method:** [How to test if mitigation works]

**New Risks Discovered:**
[Any additional risks identified during investigation]

**Risk Mitigation Experiments:**
**Experiment 1:** [Test mitigation for highest risk]
- **Approach:** [How to test the mitigation]
- **Results:** [What was learned]
- **Effectiveness:** [How well does mitigation work]

**Experiment 2:** [Test mitigation for second highest risk]
- **Approach:** [How to test the mitigation]
- **Results:** [What was learned]
- **Effectiveness:** [How well does mitigation work]

## Investigation Summary

### Architecture Decision
**Final System Architecture:**
[Summary of chosen architecture approach]

**Key Design Decisions:**
1. [Decision 1: What was decided and why]
2. [Decision 2: What was decided and why]
3. [Decision 3: What was decided and why]

### Implementation Approach
**Core Algorithm Strategy:**
[Chosen approach for implementing main algorithm]

**Data Pipeline Strategy:**
[Chosen approach for data processing]

**Integration Strategy:**
[Chosen approach for component integration]

### Validation Strategy
**Success Metrics:**
- [Metric 1: How success will be measured]
- [Metric 2: How success will be measured]
- [Metric 3: How success will be measured]

**Validation Approach:**
[How correctness and quality will be verified]

### Risk Assessment Update
**Mitigated Risks:**
[Risks that investigation successfully addressed]

**Remaining Risks:**
[Risks that still need attention during implementation]

**New Risks:**
[Any risks discovered during investigation]

## Stage Completion

### Deliverables Checklist
- [ ] **System Architecture:** Complete design with component specifications
- [ ] **Data Pipeline Design:** End-to-end data processing approach
- [ ] **Algorithm Implementation Strategy:** Detailed plan for core algorithm
- [ ] **Integration Plan:** Component connection and validation approach
- [ ] **Risk Mitigation Plan:** Specific strategies for identified risks
- [ ] **Prototype Validation:** Experiments confirming key assumptions

### Quality Validation
**Architecture Quality:**
- [ ] Design is modular and testable
- [ ] Component interfaces are clearly defined
- [ ] Data flow handles edge cases and errors
- [ ] Architecture matches available resources and skills

**Experiment Quality:**
- [ ] Prototypes successfully validate key assumptions
- [ ] Integration experiments confirm component compatibility
- [ ] Risk mitigation experiments demonstrate effectiveness
- [ ] Results provide confidence for proceeding to implementation

**Implementation Readiness:**
- [ ] Clear path forward for building each component
- [ ] Technical challenges identified with specific solutions
- [ ] Success criteria and validation methods established
- [ ] Risk mitigation strategies tested and ready

### Next Steps Decision
**Proceed to Stage 3:** [YES / NO / CONDITIONAL]

**Confidence Level:** [High / Medium / Low]

**Reasoning:**
[Why ready or not ready to proceed to specification stage]

**If Proceeding:**
- [ ] Architecture and implementation strategy validated
- [ ] Major risks mitigated with tested strategies
- [ ] Clear understanding of what needs to be built
- [ ] Ready to create detailed implementation specification

**If Not Proceeding:**
- [ ] Document specific blockers that need resolution
- [ ] Plan additional investigation or alternative approaches
- [ ] Update project context with findings and decisions

### Lessons Learned
**Key Technical Insights:**
[Important discoveries about the algorithm, architecture, or implementation approach]

**Process Improvements:**
[Notes on how to improve the investigation stage for future projects]

**Knowledge Gaps Identified:**
[Areas where additional learning is needed before implementation]

---

## Notes and Observations
[Space for additional thoughts, insights, or discoveries made during investigation]

---

*This stage should take 2-8 hours depending on complexity. Focus on validating critical assumptions through targeted experiments rather than building complete components. The goal is confidence in the implementation approach, not production-ready code.*