"""Calendar Event Endpoints."""
from typing import List, Optional
from datetime import datetime
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas.calendar import CalendarEventCreate, CalendarEventUpdate, CalendarEventResponse
from app.services.calendar_service import CalendarService
from app.core.security import get_current_user_token

router = APIRouter(prefix="/events", tags=["Calendar"])


@router.get("", response_model=List[CalendarEventResponse])
def get_events(
    workspace_id: Optional[str] = None,
    start_time: Optional[datetime] = None,
    end_time: Optional[datetime] = None,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    return CalendarService.get_events(
        db,
        workspace_id=workspace_id,
        start_time=start_time,
        end_time=end_time,
    )


@router.post("", response_model=CalendarEventResponse, status_code=status.HTTP_201_CREATED)
def create_event(
    event_in: CalendarEventCreate,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    return CalendarService.create_event(db, event_in)


@router.get("/{event_id}", response_model=CalendarEventResponse)
def get_event(
    event_id: str,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    return CalendarService.get_event(db, event_id)


@router.patch("/{event_id}", response_model=CalendarEventResponse)
def update_event(
    event_id: str,
    event_in: CalendarEventUpdate,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    return CalendarService.update_event(db, event_id, event_in)


@router.delete("/{event_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_event(
    event_id: str,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    CalendarService.delete_event(db, event_id)
