from ninja import Schema
from datetime import datetime
from typing import List, Optional
from uuid import UUID

class UserSchema(Schema):
    id: int
    username: str
    email: str

class ErrorSchema(Schema):
    message: str

class ImageOut(Schema):
    id: UUID
    title: Optional[str]
    file: str      # 图片 URL
    thumbnail: Optional[str] # 缩略图 URL
    shot_time: Optional[datetime]
    width: int
    height: int
    size: int      # 文件大小
    tags: List[str] # 标签列表
    owner: UserSchema
    created_at: datetime

# --- 新增：分页响应结构 ---
class PaginatedImageResponse(Schema):
    items: List[ImageOut]
    total: int
    page: int
    size: int
    pages: int

# --- 标签输入 ---
class TagIn(Schema):
    tag: str

# --- 更新：裁剪与色调参数 ---
class CropIn(Schema):
    x: int
    y: int
    width: int
    height: int
    rotate: int = 0        # 新增：旋转角度
    brightness: float = 1.0 # 新增：亮度 (0.0 - 2.0)
    contrast: float = 1.0   # 新增：对比度
    saturation: float = 1.0 # 新增：饱和度

# --- 批量删除 ---
class BulkDeleteIn(Schema):
    image_ids: List[UUID]