"""Project business service."""
from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.db.models import Project
from app.schemas.project import ProjectCreate, ProjectUpdate


class ProjectService:
    @staticmethod
    def get_projects(db: Session, workspace_id: Optional[str] = None) -> List[Project]:
        query = db.query(Project)
        if workspace_id:
            query = query.filter(Project.workspace_id == workspace_id)
        return query.order_by(Project.created_at.desc()).all()

    @staticmethod
    def get_project(db: Session, project_id: str) -> Project:
        project = db.query(Project).filter(Project.id == project_id).first()
        if not project:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Project not found")
        return project

    @staticmethod
    def create_project(db: Session, project_in: ProjectCreate) -> Project:
        project = Project(
            workspace_id=project_in.workspace_id,
            category_id=project_in.category_id,
            name=project_in.name,
            description=project_in.description,
            icon=project_in.icon,
            color_hex=project_in.color_hex,
            status=project_in.status,
            start_date=project_in.start_date,
            target_date=project_in.target_date,
        )
        db.add(project)
        db.commit()
        db.refresh(project)
        return project

    @staticmethod
    def update_project(db: Session, project_id: str, project_in: ProjectUpdate) -> Project:
        project = ProjectService.get_project(db, project_id)
        update_data = project_in.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(project, field, value)
        project.version += 1
        db.commit()
        db.refresh(project)
        return project

    @staticmethod
    def delete_project(db: Session, project_id: str) -> None:
        project = ProjectService.get_project(db, project_id)
        db.delete(project)
        db.commit()
