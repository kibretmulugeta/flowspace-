"""Task business service."""
from typing import List, Optional
from datetime import datetime, timezone
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.db.models import Task, Subtask
from app.schemas.task import TaskCreate, TaskUpdate, SubtaskCreate


class TaskService:
    @staticmethod
    def get_tasks(
        db: Session,
        workspace_id: Optional[str] = None,
        status_filter: Optional[str] = None,
        priority_filter: Optional[str] = None,
        project_id: Optional[str] = None,
    ) -> List[Task]:
        query = db.query(Task)
        if workspace_id:
            query = query.filter(Task.workspace_id == workspace_id)
        if status_filter:
            query = query.filter(Task.status == status_filter)
        if priority_filter:
            query = query.filter(Task.priority == priority_filter)
        if project_id:
            query = query.filter(Task.project_id == project_id)
        return query.order_by(Task.created_at.desc()).all()

    @staticmethod
    def get_task(db: Session, task_id: str) -> Task:
        task = db.query(Task).filter(Task.id == task_id).first()
        if not task:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
        return task

    @staticmethod
    def create_task(db: Session, task_in: TaskCreate) -> Task:
        task = Task(
            workspace_id=task_in.workspace_id,
            project_id=task_in.project_id,
            category_id=task_in.category_id,
            title=task_in.title,
            description=task_in.description,
            status=task_in.status,
            priority=task_in.priority,
            due_date=task_in.due_date,
            is_recurring=task_in.is_recurring,
            recurrence_rule=task_in.recurrence_rule,
        )
        db.add(task)
        db.flush()

        if task_in.subtasks:
            for sub_in in task_in.subtasks:
                sub = Subtask(
                    task_id=task.id,
                    title=sub_in.title,
                    is_completed=sub_in.is_completed,
                    subtask_order=sub_in.subtask_order,
                )
                db.add(sub)

        db.commit()
        db.refresh(task)
        return task

    @staticmethod
    def update_task(db: Session, task_id: str, task_in: TaskUpdate) -> Task:
        task = TaskService.get_task(db, task_id)
        update_data = task_in.model_dump(exclude_unset=True)

        if "status" in update_data and update_data["status"] == "completed" and not task.completed_at:
            task.completed_at = datetime.now(timezone.utc)
        elif "status" in update_data and update_data["status"] != "completed":
            task.completed_at = None

        for field, value in update_data.items():
            setattr(task, field, value)

        task.version += 1
        db.commit()
        db.refresh(task)
        return task

    @staticmethod
    def delete_task(db: Session, task_id: str) -> None:
        task = TaskService.get_task(db, task_id)
        db.delete(task)
        db.commit()
