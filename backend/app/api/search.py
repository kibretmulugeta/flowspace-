"""Global Search Endpoint."""
from typing import Optional, Dict, Any, List
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.services.search_service import SearchService
from app.core.security import get_current_user_token
from app.schemas.task import TaskResponse
from app.schemas.note import NoteResponse
from app.schemas.calendar import CalendarEventResponse
from app.schemas.project import ProjectResponse

router = APIRouter(prefix="/search", tags=["Search"])


@router.get("")
def search(
    q: str = Query(..., min_length=1, description="Search query string"),
    workspace_id: Optional[str] = None,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
) -> Dict[str, List[Any]]:
    results = SearchService.search_all(db, query_text=q, workspace_id=workspace_id or "")
    return {
        "tasks": [TaskResponse.model_validate(t) for t in results["tasks"]],
        "notes": [NoteResponse.model_validate(n) for n in results["notes"]],
        "events": [CalendarEventResponse.model_validate(e) for e in results["events"]],
        "projects": [ProjectResponse.model_validate(p) for p in results["projects"]],
    }
