# Stage 5: Implementation

**Duration:** 1-10 days (main work)  
**Started:** [Date/Time]  
**Status:** [Not Started / In Progress / Complete]  
**Estimated Completion:** [Target Date]

## Objective
Execute tickets systematically to build working POC with AI assistance and continuous validation.

## Entry Criteria Checklist
- [ ] Stage 4 completed with structured ticket list
- [ ] Execution sequence and dependencies defined
- [ ] Development environment set up and tested
- [ ] Success criteria and validation approach established

## AI Collaboration Setup

### AI Persona: Coding Partner
**Role:** Experienced developer and coding assistant across all implementation tasks
**Collaboration Level:** Variable autonomy based on task type and complexity
**Primary Tools:** GitHub Copilot, ChatGPT/Claude, specialized AI tools as needed

## Implementation Strategy

### Daily Execution Workflow
```
Morning Planning (15 minutes)
  ↓
Implementation Block 1 (2-4 hours)
  ↓
Progress Review & Planning (15 minutes)  
  ↓
Implementation Block 2 (2-4 hours)
  ↓
End-of-Day Review (15 minutes)
```

### Implementation Block Structure
1. **Ticket Selection** (5 minutes): Choose next ticket based on dependencies and priorities
2. **AI Collaboration Setup** (5 minutes): Configure AI tools and context for the ticket
3. **Implementation** (80-90%): Code, build, integrate with AI assistance
4. **Validation** (10-15%): Test against acceptance criteria and quality standards
5. **Documentation** (5%): Update code comments, docs, and progress tracking

## Daily Execution Templates

### Morning Planning Template
**Date:** [Current Date]  
**Available Time:** [Hours available today]  
**Energy Level:** [High/Medium/Low - affects ticket selection]

#### Ticket Selection
**Completed Tickets:** [List of tickets completed so far]
**Blocked Tickets:** [Tickets waiting on dependencies or external factors]
**Available Tickets:** [Tickets ready to start based on dependencies]

**Today's Target:** [Primary tickets to complete today]
1. **[TICKET-ID]:** [Title] - [Estimated duration] - [Priority reason]
2. **[TICKET-ID]:** [Title] - [Estimated duration] - [Backup if first is blocked]

**Stretch Goals:** [Additional tickets if time permits]
- **[TICKET-ID]:** [Title] - [Why it's a stretch goal]

#### Environment Setup
- [ ] Development environment active and tested
- [ ] Required tools and dependencies available
- [ ] AI collaboration tools configured (Copilot, ChatGPT access)
- [ ] Project context loaded (previous work, current state)

### Implementation Block Template

#### Block Start Checklist
**Ticket:** [TICKET-ID] - [Title]  
**Block Duration:** [Target time for this work session]  
**AI Collaboration Level:** [High/Medium/Low from ticket specification]

**Ticket Context Review:**
- **Objective:** [What this ticket accomplishes]
- **Acceptance Criteria:** [List the specific requirements]
- **Dependencies:** [What must be complete before this ticket]
- **AI Instructions:** [Specific AI collaboration guidance from ticket]

#### AI Collaboration Execution

**For High-Autonomy Tickets (AI does most work):**

##### AI Prompt Template
```markdown
**Context:** Working on ticket [TICKET-ID]: [TITLE]

**Project Context:**
- Paper: [PAPER_TITLE]
- Current Component: [COMPONENT_BEING_IMPLEMENTED]
- Integration Points: [HOW_THIS_CONNECTS_TO_OTHER_COMPONENTS]
- Project State: [WHAT_IS_ALREADY_COMPLETE]

**Ticket Requirements:**
[COPY_ACCEPTANCE_CRITERIA_FROM_TICKET]

**Specific Task:** [DETAILED_DESCRIPTION_OF_WHAT_TO_IMPLEMENT]

**Technical Specifications:**
- Input Format: [EXPECTED_INPUT_DATA_OR_PARAMETERS]
- Output Format: [EXPECTED_OUTPUT_DATA_OR_RESULTS]  
- Performance Requirements: [SPEED_MEMORY_ACCURACY_CONSTRAINTS]
- Integration Requirements: [HOW_TO_CONNECT_WITH_OTHER_COMPONENTS]

**Implementation Requirements:**
- Code Style: [FORMATTING_AND_NAMING_CONVENTIONS]
- Documentation: [COMMENT_AND_DOCSTRING_REQUIREMENTS]
- Testing: [UNIT_TEST_AND_VALIDATION_REQUIREMENTS]
- Error Handling: [HOW_TO_HANDLE_FAILURE_CASES]

**Expected Deliverables:**
- [ ] Working implementation that meets acceptance criteria
- [ ] Comprehensive unit tests with good coverage
- [ ] Clear documentation and comments
- [ ] Integration points ready for next components

**Quality Standards:**
- Code should be readable and maintainable
- All edge cases should be handled gracefully
- Performance should meet specified requirements
- Tests should cover normal and error cases
```

##### AI Response Processing
**AI Generated Code:**
```python
# [PASTE AI GENERATED CODE HERE]
```

**Human Review Checklist:**
- [ ] Code implements all acceptance criteria correctly
- [ ] Mathematical/algorithmic logic is correct
- [ ] Error handling covers realistic failure scenarios
- [ ] Code style follows project conventions
- [ ] Integration points match specification
- [ ] Performance characteristics are acceptable

**Code Modifications:**
[List any changes made to AI-generated code and why]

**For Medium-Autonomy Tickets (AI assists human-led work):**

##### Human-AI Collaboration Pattern
1. **Human:** Define approach and high-level structure
2. **AI:** Generate implementation details and boilerplate
3. **Human:** Review, modify, and integrate components
4. **AI:** Generate tests and documentation
5. **Human:** Validate correctness and integration

##### Collaboration Notes
**Human Decisions:**
- [Decision 1: What was decided and why]
- [Decision 2: What was decided and why]

**AI Contributions:**
- [Contribution 1: What AI generated or suggested]
- [Contribution 2: What AI generated or suggested]

**Integration Results:**
[How the human-AI collaboration worked for this ticket]

**For Low-Autonomy Tickets (AI provides research support):**

##### Research and Advisory Pattern
1. **Human:** Define research questions or implementation challenges
2. **AI:** Provide information, suggestions, and alternatives
3. **Human:** Make decisions and implement solutions
4. **AI:** Review and suggest improvements
5. **Human:** Finalize implementation

##### AI Research Queries
**Query 1:** [Research question or implementation challenge]
**AI Response:** [Summary of AI advice or information]
**Human Decision:** [What was decided based on AI input]

**Query 2:** [Research question or implementation challenge]
**AI Response:** [Summary of AI advice or information]
**Human Decision:** [What was decided based on AI input]

#### Validation Execution
**Acceptance Criteria Validation:**
- [ ] [Criterion 1]: [VALIDATION_RESULT_AND_EVIDENCE]
- [ ] [Criterion 2]: [VALIDATION_RESULT_AND_EVIDENCE]  
- [ ] [Criterion 3]: [VALIDATION_RESULT_AND_EVIDENCE]

**Integration Testing:**
- [ ] Component interfaces work correctly
- [ ] Data flows properly to/from other components
- [ ] Error handling works across component boundaries
- [ ] Performance meets requirements in integrated context

**Code Quality Validation:**
- [ ] Unit tests pass with good coverage
- [ ] Code follows project style guidelines
- [ ] Documentation is complete and clear
- [ ] No obvious security or performance issues

#### Ticket Completion
**Definition of Done Review:**
- [ ] All acceptance criteria met and validated
- [ ] Code reviewed and tested thoroughly
- [ ] Documentation updated (code comments, API docs, user guides)
- [ ] Integration verified with existing components
- [ ] No blocking issues for dependent tickets

**Ticket Status:** [Complete / Needs Iteration / Blocked]

**If Complete:**
- Ticket marked as done
- Dependencies updated for downstream tickets
- Next ticket selected based on priorities

**If Needs Iteration:**
- Issues identified: [List problems that need fixing]
- Estimated additional time: [Hours needed to complete]
- Plan for resolution: [Specific steps to address issues]

**If Blocked:**
- Blocking issue: [What is preventing completion]
- Escalation needed: [Who or what can unblock this]
- Alternative approach: [Workaround or different implementation]

### End-of-Day Review Template
**Date:** [Current Date]  
**Time Invested:** [Total hours worked today]

#### Daily Progress Summary
**Tickets Completed Today:**
- [TICKET-ID]: [Title] - [Actual time spent] - [Key achievements]
- [TICKET-ID]: [Title] - [Actual time spent] - [Key achievements]

**Tickets In Progress:**
- [TICKET-ID]: [Title] - [Progress percentage] - [What's left to do]

**Tickets Blocked:**
- [TICKET-ID]: [Title] - [Blocking issue] - [Plan to resolve]

#### Key Achievements
**Technical Accomplishments:**
- [Achievement 1: Major functionality implemented or working]
- [Achievement 2: Integration milestone reached]
- [Achievement 3: Performance goal achieved]

**Learning Insights:**
- [Insight 1: Technical discovery or understanding gained]
- [Insight 2: Algorithm or implementation insight]
- [Insight 3: Tool or process improvement discovered]

#### Issues and Resolutions
**Problems Encountered:**
- [Problem 1]: [Description] - [How it was resolved or current status]
- [Problem 2]: [Description] - [How it was resolved or current status]

**AI Collaboration Assessment:**
- **Most Effective:** [Where AI helped most and why]
- **Least Effective:** [Where AI struggled and what was needed instead]
- **Improvements:** [How to better collaborate with AI tomorrow]

#### Tomorrow's Plan
**Priority Tickets:**
1. [TICKET-ID]: [Title] - [Why it's priority] - [Estimated duration]
2. [TICKET-ID]: [Title] - [Why it's priority] - [Estimated duration]

**Preparation Needed:**
- [Prep item 1: Research, setup, or planning needed]
- [Prep item 2: Dependencies or external requirements]

**Risk Assessment:**
- [Risk 1: Potential issue that might cause delays]
- [Risk 2: Technical challenge that needs attention]

## Progress Tracking

### Overall Project Status
**Project Timeline:**
- **Start Date:** [When implementation began]
- **Target Completion:** [Original target date]
- **Current Estimate:** [Updated completion estimate]
- **Days Remaining:** [Available time left]

**Ticket Progress:**
- **Total Tickets:** [Total number of tickets]
- **Completed:** [Number completed] ([Percentage]%)
- **In Progress:** [Number in progress]
- **Blocked:** [Number blocked]
- **Remaining:** [Number not started]

**Phase Progress:**
- **Phase 1 (Foundation):** [Status and completion percentage]
- **Phase 2 (Core Implementation):** [Status and completion percentage]
- **Phase 3 (Integration & Validation):** [Status and completion percentage]

### Success Metrics Tracking
**Functional Requirements:**
- [Requirement 1]: [Current status and validation evidence]
- [Requirement 2]: [Current status and validation evidence]
- [Requirement 3]: [Current status and validation evidence]

**Quality Requirements:**
- [Quality metric 1]: [Current measurement and target]
- [Quality metric 2]: [Current measurement and target]
- [Quality metric 3]: [Current measurement and target]

**Performance Requirements:**
- [Performance metric 1]: [Current measurement and target]
- [Performance metric 2]: [Current measurement and target]

### Risk Management
**Active Risks:**
- [Risk 1]: [Current status and mitigation progress]
- [Risk 2]: [Current status and mitigation progress]

**New Risks Identified:**
- [New risk 1]: [Description, likelihood, impact, mitigation plan]
- [New risk 2]: [Description, likelihood, impact, mitigation plan]

**Risk Mitigation Effectiveness:**
- [Mitigation 1]: [How well it's working and any adjustments needed]
- [Mitigation 2]: [How well it's working and any adjustments needed]

## Quality Assurance

### Continuous Integration Checklist
**Daily Quality Gates:**
- [ ] All unit tests passing
- [ ] No security vulnerabilities in new code
- [ ] Code coverage maintaining acceptable levels
- [ ] Performance benchmarks within acceptable range
- [ ] Integration tests passing for affected components

### Code Quality Monitoring
**Code Quality Metrics:**
- **Test Coverage:** [Current percentage and target]
- **Code Complexity:** [Complexity metrics and acceptability]
- **Documentation Coverage:** [API docs, comments, user guides status]
- **Technical Debt:** [Known issues and plan for addressing]

### Validation Strategy Execution
**Component-Level Validation:**
- [Component 1]: [Validation status and results]
- [Component 2]: [Validation status and results]
- [Component 3]: [Validation status and results]

**Integration Validation:**
- **Data Flow:** [End-to-end data processing validation]
- **Component Communication:** [Interface validation results]
- **Error Handling:** [System-level error handling validation]

**System-Level Validation:**
- **Functional Testing:** [Complete workflow validation]
- **Performance Testing:** [Speed, memory, scalability validation]
- **Acceptance Testing:** [Validation against original success criteria]

## Troubleshooting and Debugging

### Common Issues and Solutions
**AI Collaboration Issues:**
- **AI generates incorrect code:** [Strategies for better prompting and validation]
- **AI suggestions don't fit architecture:** [How to provide better context]
- **AI can't understand complex requirements:** [When to break down tasks further]

**Technical Implementation Issues:**
- **Algorithm doesn't match paper:** [Debugging and validation approaches]
- **Performance issues:** [Profiling and optimization strategies]
- **Integration failures:** [Interface debugging and resolution methods]

**Project Management Issues:**
- **Tickets taking longer than estimated:** [Re-estimation and scope adjustment]
- **Dependencies causing delays:** [Dependency management and workarounds]
- **Scope creep:** [How to maintain focus on core objectives]

### Debugging Support Templates

#### AI Debugging Assistance
```markdown
**Context:** Debugging issue in [COMPONENT] while working on [TICKET-ID]

**Problem Description:**
- Expected Behavior: [What should happen]
- Actual Behavior: [What is happening]
- Error Messages: [Specific errors or symptoms]
- Reproduction Steps: [How to trigger the issue]

**Code Context:**
[RELEVANT CODE SNIPPET]

**Analysis Needed:**
- Root cause identification
- Solution recommendations  
- Prevention strategies for similar issues
- Testing approaches to validate fix

**Constraints:**
- Must maintain interface compatibility
- Performance requirements: [SPECIFIC_NEEDS]
- Cannot break existing functionality
- Solution should be maintainable and clear
```

#### Performance Optimization Support
```markdown
**Context:** Optimizing [COMPONENT] performance for [SPECIFIC_REQUIREMENT]

**Current Performance:**
- Speed: [Current measurements]
- Memory: [Current usage]
- Scalability: [Current limits]

**Target Performance:**
- Speed: [Target requirements]
- Memory: [Target limits]
- Scalability: [Target capacity]

**Optimization Request:**
- Profile current implementation to identify bottlenecks
- Suggest optimization strategies
- Provide optimized code alternatives
- Recommend performance testing approaches

**Constraints:**
- Cannot change external interfaces
- Must maintain algorithmic correctness
- Should improve maintainability if possible
```

## Project Completion

### Final Validation Checklist
**Functional Completeness:**
- [ ] All core algorithm functionality implemented and working
- [ ] Data pipeline processes all required data types correctly
- [ ] End-to-end system executes without manual intervention
- [ ] Results are interpretable and align with expected outcomes

**Quality Standards:**
- [ ] Code quality meets established standards
- [ ] Test coverage exceeds minimum requirements
- [ ] Documentation is complete and usable
- [ ] Performance meets specified requirements

**Success Criteria Validation:**
- [ ] [Success criterion 1]: [Validation evidence]
- [ ] [Success criterion 2]: [Validation evidence]
- [ ] [Success criterion 3]: [Validation evidence]

### Deliverables Preparation
**Working POC System:**
- [ ] Complete source code with clear organization
- [ ] All components integrated and functional
- [ ] Configuration and setup scripts
- [ ] Sample data and test cases

**Documentation Package:**
- [ ] Setup and installation instructions
- [ ] Usage guide with examples
- [ ] Technical documentation (architecture, implementation notes)
- [ ] API documentation for major components

**Demonstration Materials:**
- [ ] Demo script or walkthrough
- [ ] Sample inputs and expected outputs
- [ ] Performance benchmarks and validation results
- [ ] Presentation materials (if needed)

### Project Retrospective
**What Worked Well:**
- [Success factor 1]: [Why it worked and how to repeat]
- [Success factor 2]: [Why it worked and how to repeat]
- [Success factor 3]: [Why it worked and how to repeat]

**What Could Be Improved:**
- [Improvement area 1]: [What went wrong and how to avoid]
- [Improvement area 2]: [What went wrong and how to avoid]
- [Improvement area 3]: [What went wrong and how to avoid]

**AI Collaboration Assessment:**
- **Most Valuable AI Contributions:** [Where AI helped most]
- **AI Limitations Encountered:** [Where AI struggled]
- **Collaboration Improvements:** [How to work better with AI next time]

**Technical Learnings:**
- [Learning 1]: [Technical insight gained]
- [Learning 2]: [Technical insight gained]
- [Learning 3]: [Technical insight gained]

**Process Learnings:**
- [Process insight 1]: [Workflow or methodology improvement]
- [Process insight 2]: [Workflow or methodology improvement]

### Knowledge Transfer
**Implementation Insights:**
[Key technical discoveries and decisions that future implementers should know]

**Reusable Components:**
[Code, patterns, or approaches that could be applied to other projects]

**Best Practices Identified:**
[Effective approaches for similar projects]

**Lessons Learned:**
[What to do differently next time]

---

## Notes and Observations
[Space for ongoing thoughts, insights, and discoveries during implementation]

---

*This stage represents the main work of the project. Stay focused on the success criteria while being flexible about implementation details. Document insights as you go - they're often more valuable than the code itself.*