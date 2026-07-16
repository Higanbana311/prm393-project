# <a name="agents.md"></a>AGENTS.md
## <a name="flutter-ai-agent-rules"></a>Flutter AI Agent Rules
### <a name="primary-objective"></a>Primary Objective
Make the smallest correct change possible.

Never scan the entire repository before understanding the task.

Always load context progressively.

-----
## <a name="repository-exploration-rules"></a>Repository Exploration Rules
### <a name="do-not-read-the-whole-project"></a>DO NOT READ THE WHOLE PROJECT
Before implementing anything:

1. Read README.md
1. Read pubspec.yaml
1. Find the feature related to the task
1. Read at most 5 files initially
1. Expand context only when necessary
-----
## <a name="context-budget"></a>Context Budget
### <a name="initial-context"></a>Initial Context
Allowed:

- README.md
- pubspec.yaml
- lib/main.dart
- router configuration
- feature directly mentioned in task

Maximum initial files: 5
### <a name="additional-context"></a>Additional Context
Only read more files when:

- Current file imports them
- They are directly involved in the requested feature
- Compilation errors require investigation
### <a name="never-scan-automatically"></a>Never Scan Automatically
Do not recursively read:

- build/
- .dart\_tool/
- android/build/
- ios/build/
- generated/
- coverage/
-----
## <a name="flutter-architecture-discovery"></a>Flutter Architecture Discovery
When entering a new project:
### <a name="step-1"></a>Step 1
Identify architecture:

- Clean Architecture
- Feature First
- MVVM
- BLoC
- Provider
- Riverpod
- GetX
- Redux
### <a name="step-2"></a>Step 2
Locate:

- Routing
- Dependency injection
- State management
- API layer
- Models
### <a name="step-3"></a>Step 3
Create a mental map before editing.

-----
## <a name="file-investigation-strategy"></a>File Investigation Strategy
### <a name="for-ui-changes"></a>For UI Changes
Read only:

1. Screen
1. Widget used by screen
1. Related state management file

Avoid reading unrelated features.

-----
### <a name="for-api-changes"></a>For API Changes
Read only:

1. Repository
1. Data source
1. Model
1. Related state management

Avoid reading UI unless required.

-----
### <a name="for-bug-fixes"></a>For Bug Fixes
Read:

1. Failing screen
1. State management
1. Service/repository
1. Test if available

Do not inspect unrelated modules.

-----
## <a name="flutter-coding-standards"></a>Flutter Coding Standards
### <a name="widgets"></a>Widgets
Prefer:

const Text('Hello')

Avoid:

Text('Hello')

when const is possible.

-----
### <a name="build-methods"></a>Build Methods
Keep build methods simple.

If widget exceeds 150 lines:

- Extract widgets
- Extract helper methods
-----
### <a name="state-management"></a>State Management
Follow existing pattern.

Do not introduce:

- Riverpod into Provider project
- Provider into BLoC project
- GetX into Riverpod project

unless explicitly requested.

-----
### <a name="async-operations"></a>Async Operations
Always:

**try** {\
...\
} **catch** (e) {\
...\
}

Handle loading and error states.

Never silently swallow exceptions.

-----
### <a name="models"></a>Models
Prefer immutable models.

Use:

- freezed
- json\_serializable

if project already uses them.

Do not introduce new model patterns.

-----
## <a name="feature-development-workflow"></a>Feature Development Workflow
### <a name="before-coding"></a>Before Coding
Identify:

- Screen
- State
- Repository
- Model

Understand data flow.
### <a name="during-coding"></a>During Coding
Change the minimum number of files.

Avoid unnecessary refactors.
### <a name="after-coding"></a>After Coding
Run only:

dart analyze path/to/file.dart

or

flutter test test/specific\_test.dart

Do not run the entire test suite unless requested.

-----
## <a name="testing-rules"></a>Testing Rules
### <a name="preferred-order"></a>Preferred Order
1. Existing tests
1. Feature tests
1. Widget tests
1. Integration tests
### <a name="when-fixing-bugs"></a>When Fixing Bugs
Attempt to create or update a test reproducing the issue.

-----
## <a name="performance-rules"></a>Performance Rules
### <a name="lists"></a>Lists
Prefer:

ListView.builder()

Avoid:

Column(\
`  `children: largeList\
)

for large datasets.

-----
### <a name="rebuild-optimization"></a>Rebuild Optimization
Use:

- const widgets
- selectors
- Consumer
- Riverpod select

when appropriate.

Avoid rebuilding entire screens.

-----
## <a name="dependency-rules"></a>Dependency Rules
Do not add packages unless necessary.

Before adding a dependency:

1. Check existing package usage
1. Check Flutter SDK capability
1. Request approval
-----
## <a name="safe-operations"></a>Safe Operations
Allowed:

- Read files
- Search code
- Analyze single file
- Run single test

Require approval:

- flutter clean
- full build
- dependency changes
- pubspec.yaml modification
- deleting files
- schema migrations
-----
## <a name="feature-mapping"></a>Feature Mapping
Before reading more files:

Answer:

1. Which feature is affected?
1. Which state manager is involved?
1. Which repository is involved?
1. Which API is involved?
1. Which model is involved?

If unknown, search first.

Never read random files.

-----
## <a name="hard-limits"></a>Hard Limits
Maximum initial files: 5

Maximum files per iteration: 10

Maximum exploration time: 20%

Minimum implementation time: 80%

Do not spend more time exploring than coding.

-----
## <a name="when-stuck"></a>When Stuck
1. Search feature name
1. Search route name
1. Search repository usage
1. Search state management usage

Ask for clarification before reading large portions of the codebase.

-----
## <a name="final-rule"></a>Final Rule
Read less.

Understand more.

Modify only what is necessary.
