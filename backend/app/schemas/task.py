"""Task and Subtask Schemas."""
from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel


class SubtaskBase(BaseModel):
    title: str
    is_completed: bool = False
    subtask_order: int = 0


class SubtaskCreate(SubtaskBase):
    pass


class SubtaskResponse(SubtaskBase):
    id: str
    task_id: str
    created_at: datetime

    class Config:
        from_attributes = True


class TaskBase(BaseModel):
    title: str
    description: Optional[str] = None
    status: str = "todo"
    priority: str = "none"
    due_date: Optional[datetime] = None
    project_id: Optional[str] = None
    category_id: Optional[str] = None
    is_recurring: bool = False
    recurrence_rule: Optional[str] = None


class TaskCreate(TaskBase):
    workspace_id: str
    subtasks: Optional[List[SubtaskCreate]] = []


class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = None
    priority: Optional[str] = None
    due_date: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    project_id: Optional[str] = None
    category_id: Optional[str] = None
    is_recurring: Optional[bool] = None
    recurrence_rule: Optional[str] = None


class TaskResponse(TaskBase):
    id: str
    workspace_id: str
    completed_at: Optional[datetime] = None
    version: int
    created_at: datetime
    updated_at: datetime
    subtasks: List[SubtaskResponse] = []

    class Config:
        from_attributes = True
