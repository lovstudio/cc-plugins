---
allowed-tools: [TodoWrite]
description: "Dynamically add tasks to the current todo list with priority control during task execution"
version: "1.0.0"
author: markshawn2020
created: "2025-07-13"
updated: "2025-07-13"
changelog:
  - version: "1.0.0"
    date: "2025-07-13"
    changes: ["Initial version - dynamic task addition with priority control"]
aliases: "/add-task"---

# Add Task Command

You are helping the user add a new task to their current todo list during active task execution.

## Command Usage
This command accepts the following format:
- `/add-task "task description" [priority] [position]`
- Priority: high|medium|low (defaults to medium)
- Position: before|after|top|bottom (defaults to bottom)

## Instructions

1. **Parse the command arguments**:
   - Extract the task description (required)
   - Extract priority level (optional, defaults to "medium")
   - Extract position preference (optional, defaults to "bottom")

2. **Add the task intelligently**:
   - If there's an existing todo list, add to it appropriately
   - If no todo list exists, create one with the new task
   - Respect the position preference when adding
   - Generate a unique ID for the new task

3. **Position Logic**:
   - `top`: Add as first item
   - `bottom`: Add as last item (default)
   - `before`: Add before any in_progress tasks
   - `after`: Add after any in_progress tasks

4. **Priority Handling**:
   - Set the priority as specified (high/medium/low)
   - If priority is "high", consider placing it near the top regardless of position preference

5. **Preserve Existing State**:
   - Keep all existing tasks and their current status
   - Don't modify existing task priorities or states
   - Maintain existing task IDs

## Example Usage

User input: `/add-task "Fix login validation bug" high before`

Your response should:
1. Add "Fix login validation bug" with high priority
2. Place it before any currently in_progress tasks
3. Use TodoWrite to update the complete todo list
4. Confirm the task was added

## Response Format

After adding the task, provide a brief confirmation:
- "Added task: [task description] (priority: [priority]) at [position]"
- Don't provide unnecessary explanations unless requested

Remember to use the TodoWrite tool to actually update the todo list.