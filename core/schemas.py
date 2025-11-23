from ninja import Schema
from datetime import datetime
from typing import List, Optional, Dict, Any
from uuid import UUID

class UserSchema(Schema):
    id: int
    username: str
    email: str

class ImageOut(Schema):
    id: UUID
    title: Optional[str]
    file: str      # 图片 URL
    thumbnail: Optional[str] # 缩略图 URL
    shot_time: Optional[datetime]
    width: int
    height: int
    size: int
    tags: List[str] # 标签列表
    owner: UserSchema
    created_at: datetime