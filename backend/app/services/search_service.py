"""Global multi-entity search service."""
from typing import Dict, Any, List
from sqlalchemy.orm import Session
from app.db.models import Task, Note, CalendarEvent, Project


class SearchService:
    @staticmethod
    def search_all(db: Session, query_text: str, workspace_id: str = "") -> Dict[str, List[Any]]:
        pattern = f"%{query_text}%"

        tasks_q = db.query(Task).filter(Task.title.ilike(pattern))
        notes_q = db.query(Note).filter(Note.title.ilike(pattern))
        events_q = db.query(CalendarEvent).filter(CalendarEvent.title.ilike(pattern))
        projects_q = db.query(Project).filter(Project.name.ilike(pattern))

        if workspace_id:
            tasks_q = tasks_q.filter(Task.workspace_id == workspace_id)
            notes_q = notes_q.filter(Note.workspace_id == workspace_id)
            events_q = events_q.filter(CalendarEvent.workspace_id == workspace_id)
            projects_q = projects_q.filter(Project.workspace_id == workspace_id)

        return {
            "tasks": tasks_q.limit(20).all(),
            "notes": notes_q.limit(20).all(),
            "events": events_q.limit(20).all(),
            "projects": projects_q.limit(20).all(),
        }
