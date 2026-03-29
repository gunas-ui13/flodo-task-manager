from pydantic import BaseModel
from typing import Optional

# This is the base structure for a task
class TaskBase(BaseModel):
    title: str
    description: str
    due_date: str
    status: str = "To-Do"
    blocked_by_task_id: Optional[int] = None

# We use this when creating a new task
class TaskCreate(TaskBase):
    pass

# We use this when updating an existing task
class TaskUpdate(TaskBase):
    pass

# This is what the API sends back to the Flutter app (it includes the ID)
class TaskResponse(TaskBase):
    id: int

    class Config:
        from_attributes = True