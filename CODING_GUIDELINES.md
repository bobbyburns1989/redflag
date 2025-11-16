# Pink Flag - Coding Guidelines for Claude Code

> **Purpose**: These guidelines ensure consistent collaboration between developers and Claude Code AI assistant for the Pink Flag mobile app project.

---

## 🤖 Working with Claude Code

**Initial Session Behavior:**
- Begin by reading relevant project files to understand context
- Note important details about architecture, recent changes, and current state
- Suggest best paths forward based on analysis
- **DO NOT make any changes until explicitly approved** by the developer

---

## 📋 Core Principles

### 1. **Concise Communication**
- Keep explanations concise and to the point
- Avoid over-engineering solutions
- Solutions should be appropriate for apps with **fewer than 5k active users**
- No premature optimization

### 2. **Explicit Authorization Required**
- Only push to GitHub when requested
- Only run the app when requested
- Only run scripts when permission is granted
- Ask before making significant architectural changes

### 3. **Clarification Before Action**
- If a task description is unclear, ask clarifying questions first
- Never make assumptions about requirements
- Confirm understanding before proceeding with implementation

### 4. **Context Awareness**
- Use all provided context: file paths, project structure, error messages, requirements
- If additional information is needed, request it explicitly
- Stay mindful of the current stage of app development

---

## 🛠️ Implementation Approach

### Complex Tasks Process

For multi-step or complex tasks, follow this workflow:

1. **Plan Phase**
   - Outline your approach clearly
   - Present 2-3 alternative approaches when appropriate
   - Include trade-offs for each approach
   - Recommend the best option for our specific requirements
   - Build a step-by-step plan and summarize it

2. **Implementation Phase**
   - Implement steps separately (not all at once)
   - Provide initial implementations
   - Wait for feedback between major steps

3. **Refinement Phase**
   - Iterate and refine based on feedback
   - Review the complete solution
   - Test and validate changes

### Code Quality Standards

**Code Comments:**
- Include detailed comments about:
  - Implementation decisions and why they were made
  - Function behavior and expected inputs/outputs
  - Edge cases to be aware of
  - Performance implications
  - Security considerations

**Code Review Checklist:**
When reviewing code, highlight:
- Potential bugs and logic errors
- Performance issues or bottlenecks
- Security concerns or vulnerabilities
- Adherence to Flutter/Dart best practices
- Code readability and maintainability
- Test coverage gaps

---

## 💡 Communication Style

### Explanations
- Use plain language for technical concepts
- Provide concrete code examples with context
- Include sample inputs and outputs when helpful
- Link to relevant documentation when appropriate

### Collaboration
- Verify changes and their implications
- Explain the impact of suggested changes
- Suggest testing strategies for critical code
- Provide concise progress updates
- Document changes in commit messages and changelogs

---

## 📚 Documentation

### Keep Documentation Current
- Update README.md when user-facing features change
- Update DEVELOPER_GUIDE.md when architecture changes
- Update AESTHETIC_ENHANCEMENT_PROGRESS.md when UI/UX changes
- Create inline code documentation for complex logic
- Document API changes in both frontend and backend

### Documentation Standards
- Use clear markdown formatting
- Include code examples where appropriate
- Keep file references accurate (file paths and line numbers)
- Update "Last Updated" dates

---

## 🎯 Project-Specific Context

### Pink Flag App Details
- **Target Audience**: Women's safety app users (< 5k active users initially)
- **Privacy-First**: No login, no tracking, no data collection
- **Technology**: Flutter (frontend) + FastAPI Python (backend)
- **Design Philosophy**: Simple, elegant, accessible
- **Theme**: Pink gradient aesthetic with Material 3

### Development Priorities (in order)
1. **Functionality**: Core features must work reliably
2. **Privacy & Security**: Ethical design, no data leakage
3. **User Experience**: Intuitive, accessible, beautiful
4. **Performance**: Fast, responsive, efficient
5. **Maintainability**: Clean, documented, testable code

### Current Development Stage
- ✅ Phase 1-8: Complete aesthetic enhancement (Nov 2025)
- 🎯 Current Focus: Production deployment preparation
- 📋 Next: App Store and Play Store submission

---

## ⚡ Quick Reference

### Before Starting Any Task
1. ✅ Read relevant files to understand context
2. ✅ Check git status for uncommitted changes
3. ✅ Review recent commits and documentation
4. ✅ Understand the current development stage
5. ✅ Clarify unclear requirements

### During Implementation
1. ✅ Follow the Implementation Approach (Plan → Implement → Refine)
2. ✅ Write detailed code comments
3. ✅ Use TodoWrite tool for tracking progress on complex tasks
4. ✅ Test changes locally before committing
5. ✅ Update documentation as you go

### After Completing Tasks
1. ✅ Run code quality checks (`flutter analyze`, `dart format`)
2. ✅ Update relevant documentation files
3. ✅ Provide concise summary of changes
4. ✅ Suggest next steps or potential improvements
5. ✅ Ask if user wants to commit changes (don't commit automatically)

---

## 🚫 What NOT to Do

- ❌ Don't push to GitHub without explicit request
- ❌ Don't run the app without explicit request
- ❌ Don't make changes before getting approval
- ❌ Don't over-engineer solutions for small user base
- ❌ Don't assume requirements without clarification
- ❌ Don't skip documentation updates
- ❌ Don't commit changes automatically
- ❌ Don't run scripts without permission
- ❌ Don't make assumptions about user intent

---

## 🤝 Example Workflow

**Good Workflow:**
```
User: "Add a favorites feature to save searches"

Claude Code:
1. Reads search_screen.dart, api_service.dart, models
2. Notes: Privacy-first approach, no backend persistence
3. Presents 3 approaches:
   - Option A: SharedPreferences (local only, simple)
   - Option B: SQLite (local only, more features)
   - Option C: Encrypted local storage (most secure)
4. Recommends Option A for simplicity given <5k users
5. Outlines step-by-step plan
6. Waits for approval before implementing
```

**Bad Workflow:**
```
User: "Add a favorites feature"

Claude Code:
❌ Immediately starts coding without clarification
❌ Implements cloud sync without discussing privacy
❌ Over-engineers with Redux state management
❌ Pushes to GitHub without permission
❌ No documentation updates
```

---

## 📞 Questions to Ask

### When Requirements Are Unclear
- "Should this feature persist data locally or on a backend?"
- "What's the expected user flow for this feature?"
- "Are there any privacy considerations for this feature?"
- "Should this work offline?"
- "Do you want me to update the documentation now or later?"

### Before Major Changes
- "This will require changes to [X, Y, Z] files. Should I proceed?"
- "I found a potential issue with [X]. Should I fix it now or create a separate task?"
- "This could be implemented in [A] or [B] way. Which approach do you prefer?"

---

## ✅ Success Criteria

Claude Code is being a good assistant when:
- ✅ Changes are approved before implementation
- ✅ Communication is clear and concise
- ✅ Code is well-documented and maintainable
- ✅ Solutions are appropriately scoped for app scale
- ✅ Documentation stays current
- ✅ Progress is tracked and visible
- ✅ Questions are asked when needed
- ✅ Testing strategies are suggested

---

**Document Version**: 1.0
**Last Updated**: November 6, 2025
**Next Review**: After first App Store release

---

## 📖 Related Documentation
- [DEVELOPER_GUIDE.md](./DEVELOPER_GUIDE.md) - Comprehensive developer onboarding
- [README.md](./README.md) - User-facing project documentation
- [AESTHETIC_ENHANCEMENT_PROGRESS.md](./AESTHETIC_ENHANCEMENT_PROGRESS.md) - UI/UX enhancement log
