"""Projects Endpoints."""
from typing import List, Optional
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas.project import ProjectCreate, ProjectUpdate, ProjectResponse
from app.services.project_service import ProjectService
from app.core.security import get_current_user_token

router = APIRouter(prefix="/projects", tags=["Projects"])


@router.get("", response_model=List[ProjectResponse])
def get_projects(
    workspace_id: Optional[str] = None,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    return ProjectService.get_projects(db, workspace_id=workspace_id)


@router.post("", response_model=ProjectResponse, status_code=status.HTTP_201_CREATED)
def create_project(
    project_in: ProjectCreate,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    return ProjectService.create_project(db, project_in)


@router.get("/{project_id}", response_model=ProjectResponse)
def get_project(
    project_id: str,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    return ProjectService.get_project(db, project_id)


@router.patch("/{project_id}", response_model=ProjectResponse)
def update_project(
    project_id: str,
    project_in: ProjectUpdate,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    return ProjectService.update_project(db, project_id, project_in)


@router.delete("/{project_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_project(
    project_id: str,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    ProjectService.delete_project(db, project_id)
