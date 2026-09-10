"""Task Endpoints."""
from typing import List, Optional
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas.task import TaskCreate, TaskUpdate, TaskResponse
from app.services.task_service import TaskService
from app.core.security import get_current_user_token

router = APIRouter(prefix="/tasks", tags=["Tasks"])


@router.get("", response_model=List[TaskResponse])
def get_tasks(
    workspace_id: Optional[str] = None,
    status: Optional[str] = None,
    priority: Optional[str] = None,
    project_id: Optional[str] = None,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    return TaskService.get_tasks(
        db,
        workspace_id=workspace_id,
        status_filter=status,
        priority_filter=priority,
        project_id=project_id,
    )


@router.post("", response_model=TaskResponse, status_code=status.HTTP_201_CREATED)
def create_task(
    task_in: TaskCreate,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    return TaskService.create_task(db, task_in)


@router.get("/{task_id}", response_model=TaskResponse)
def get_task(
    task_id: str,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    return TaskService.get_task(db, task_id)


@router.patch("/{task_id}", response_model=TaskResponse)
def update_task(
    task_id: str,
    task_in: TaskUpdate,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    return TaskService.update_task(db, task_id, task_in)


@router.delete("/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_task(
    task_id: str,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    TaskService.delete_task(db, task_id)
