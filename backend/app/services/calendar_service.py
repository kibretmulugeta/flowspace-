"""Calendar Event business service."""
from typing import List, Optional
from datetime import datetime
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.db.models import CalendarEvent
from app.schemas.calendar import CalendarEventCreate, CalendarEventUpdate


class CalendarService:
    @staticmethod
    def get_events(
        db: Session,
        workspace_id: Optional[str] = None,
        start_time: Optional[datetime] = None,
        end_time: Optional[datetime] = None,
    ) -> List[CalendarEvent]:
        query = db.query(CalendarEvent)
        if workspace_id:
            query = query.filter(CalendarEvent.workspace_id == workspace_id)
        if start_time:
            query = query.filter(CalendarEvent.end_time >= start_time)
        if end_time:
            query = query.filter(CalendarEvent.start_time <= end_time)
        return query.order_by(CalendarEvent.start_time.asc()).all()

    @staticmethod
    def get_event(db: Session, event_id: str) -> CalendarEvent:
        event = db.query(CalendarEvent).filter(CalendarEvent.id == event_id).first()
        if not event:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")
        return event

    @staticmethod
    def create_event(db: Session, event_in: CalendarEventCreate) -> CalendarEvent:
        event = CalendarEvent(
            workspace_id=event_in.workspace_id,
            calendar_id=event_in.calendar_id,
            category_id=event_in.category_id,
            title=event_in.title,
            description=event_in.description,
            start_time=event_in.start_time,
            end_time=event_in.end_time,
            is_all_day=event_in.is_all_day,
            location=event_in.location,
            color_hex=event_in.color_hex,
            recurrence_rule=event_in.recurrence_rule,
        )
        db.add(event)
        db.commit()
        db.refresh(event)
        return event

    @staticmethod
    def update_event(db: Session, event_id: str, event_in: CalendarEventUpdate) -> CalendarEvent:
        event = CalendarService.get_event(db, event_id)
        update_data = event_in.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(event, field, value)
        event.version += 1
        db.commit()
        db.refresh(event)
        return event

    @staticmethod
    def delete_event(db: Session, event_id: str) -> None:
        event = CalendarService.get_event(db, event_id)
        db.delete(event)
        db.commit()
