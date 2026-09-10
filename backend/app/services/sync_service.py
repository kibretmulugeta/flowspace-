"""Batch Outbox Synchronization service."""
from datetime import datetime, timezone
from typing import Dict, Any, List
from sqlalchemy.orm import Session
from app.db.models import SyncOutboxAudit, Task, Note, CalendarEvent, Project, Reminder
from app.schemas.sync import BatchSyncRequest, BatchSyncResponse


class SyncService:
    @staticmethod
    def process_batch(db: Session, user_id: str, batch: BatchSyncRequest) -> BatchSyncResponse:
        processed_ids: List[str] = []
        conflicts: List[Dict[str, Any]] = []

        for action in batch.actions:
            # 1. Audit log the incoming client mutation
            audit = SyncOutboxAudit(
                user_id=user_id,
                client_id=batch.client_id,
                action_id=action.action_id,
                entity_type=action.entity_type,
                action_type=action.action_type,
                entity_id=action.entity_id,
                payload=action.payload,
            )
            db.add(audit)

            # 2. Process based on entity type
            try:
                if action.entity_type == "task":
                    if action.action_type == "delete":
                        task = db.query(Task).filter(Task.id == action.entity_id).first()
                        if task:
                            db.delete(task)
                    elif action.action_type in ("create", "update"):
                        task = db.query(Task).filter(Task.id == action.entity_id).first()
                        if not task:
                            task = Task(id=action.entity_id, **action.payload)
                            db.add(task)
                        else:
                            for k, v in action.payload.items():
                                if hasattr(task, k):
                                    setattr(task, k, v)
                            task.version += 1

                elif action.entity_type == "event":
                    if action.action_type == "delete":
                        ev = db.query(CalendarEvent).filter(CalendarEvent.id == action.entity_id).first()
                        if ev:
                            db.delete(ev)
                    elif action.action_type in ("create", "update"):
                        ev = db.query(CalendarEvent).filter(CalendarEvent.id == action.entity_id).first()
                        if not ev:
                            ev = CalendarEvent(id=action.entity_id, **action.payload)
                            db.add(ev)
                        else:
                            for k, v in action.payload.items():
                                if hasattr(ev, k):
                                    setattr(ev, k, v)
                            ev.version += 1

                elif action.entity_type == "reminder":
                    if action.action_type == "delete":
                        rem = db.query(Reminder).filter(Reminder.id == action.entity_id).first()
                        if rem:
                            db.delete(rem)
                    elif action.action_type in ("create", "update"):
                        rem = db.query(Reminder).filter(Reminder.id == action.entity_id).first()
                        if not rem:
                            rem = Reminder(id=action.entity_id, **action.payload)
                            db.add(rem)
                        else:
                            for k, v in action.payload.items():
                                if hasattr(rem, k):
                                    setattr(rem, k, v)
                            rem.version += 1

                processed_ids.append(action.action_id)
            except Exception as e:
                conflicts.append({
                    "action_id": action.action_id,
                    "entity_id": action.entity_id,
                    "error": str(e),
                })

        db.commit()

        return BatchSyncResponse(
            success=len(conflicts) == 0,
            processed_action_ids=processed_ids,
            conflicts=conflicts,
            server_sync_time=datetime.now(timezone.utc),
        )
