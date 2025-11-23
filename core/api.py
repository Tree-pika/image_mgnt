from ninja import NinjaAPI, Router, File, Schema
from ninja.files import UploadedFile
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from django.db.models import Q
from django.conf import settings
from django.utils import timezone # 必须导入
from .models import Image
# 确保导入了 BulkDeleteIn
from .schemas import ImageOut, UserSchema, ErrorSchema, TagIn, CropIn, BulkDeleteIn, PaginatedImageResponse
import os
import exifread
import uuid # 必须导入
from uuid import UUID # 类型提示用
from PIL import Image as PilImage, ImageEnhance
from datetime import datetime
from io import BytesIO
from django.core.files.base import ContentFile
from django.http import HttpRequest
from django.db import IntegrityError
from pydantic import EmailStr
from typing import List
import math

# 实例化 API 对象
api = NinjaAPI()
router = Router()

User = get_user_model()

# --- Schemas ---

class RegisterSchema(Schema):
    username: str
    password: str
    email: EmailStr 

class LoginSchema(Schema):
    username: str
    password: str

# --- API Endpoints ---

@api.post("/auth/register", response={200: UserSchema, 400: ErrorSchema})
def register(request, data: RegisterSchema):
    if len(data.password) < 6:
        return 400, {"message": "密码长度至少需要6位"}
    try:
        user = User.objects.create_user(
            username=data.username,
            password=data.password,
            email=data.email
        )
        return 200, user
    except IntegrityError:
        return 400, {"message": "用户名或邮箱已存在"}

@api.post("/auth/login", response={200: UserSchema, 400: ErrorSchema})
def user_login(request: HttpRequest, data: LoginSchema):
    username = data.username
    if '@' in username:
        user_obj = User.objects.filter(email=username).first()
        if user_obj:
            username = user_obj.username
    
    user = authenticate(username=username, password=data.password)
    
    if user:
        login(request, user)
        return 200, user
    else:
        return 400, {"message": "账号或密码错误"}

@api.post("/auth/logout")
def user_logout(request: HttpRequest):
    logout(request)
    return {"success": True}

@api.get("/auth/me", response={200: UserSchema, 403: ErrorSchema})
def me(request: HttpRequest):
    if request.user.is_authenticated:
        return 200, request.user
    return 403, {"message": "未登录"}

# --- 图片管理接口 ---

def parse_exif_date(date_str):
    if not date_str: return None
    try: return datetime.strptime(str(date_str), '%Y:%m:%d %H:%M:%S')
    except ValueError: return None

# 1. 升级：分页获取图片列表
@router.get("/images", response=PaginatedImageResponse)
def list_images(request, search: str = None, tag: str = None, trash: bool = False, page: int = 1, size: int = 12):
    if not request.user.is_authenticated:
        return {"items": [], "total": 0, "page": page, "size": size, "pages": 0}

    qs = Image.objects.filter(owner=request.user)
    
    # 筛选逻辑
    if trash:
        qs = qs.filter(deleted_at__isnull=False)
    else:
        qs = qs.filter(deleted_at__isnull=True)
    
    if search:
        qs = qs.filter(
            Q(title__icontains=search) | 
            Q(location__icontains=search) |
            Q(tags__contains=search)
        )
    
    if tag:
        tag_list = tag.split(',')
        for t in tag_list:
            if t.strip():
                qs = qs.filter(tags__contains=t.strip())
    
    # --- 分页逻辑 ---
    total = qs.count()
    qs = qs.order_by('-created_at')
    
    start = (page - 1) * size
    end = start + size
    items = list(qs[start:end]) # 切片查询
    
    pages = math.ceil(total / size)
    
    return {
        "items": items,
        "total": total,
        "page": page,
        "size": size,
        "pages": pages
    }

# 2. 上传图片
@router.post("/upload", response=ImageOut, auth=None) 
def upload_image(request, file: UploadedFile = File(...)):
    if not request.user.is_authenticated:
        from ninja.errors import HttpError
        raise HttpError(401, "请先登录")
    
    user = request.user
    tags = exifread.process_file(file.file)
    file.file.seek(0) 

    exif_data = {}
    shot_time = None
    
    if 'EXIF DateTimeOriginal' in tags:
        date_str = str(tags['EXIF DateTimeOriginal'])
        shot_time = parse_exif_date(date_str)
        exif_data['DateTimeOriginal'] = date_str
    if 'Image Model' in tags:
        exif_data['Model'] = str(tags['Image Model'])

    pil_img = PilImage.open(file.file)
    width, height = pil_img.size
    
    thumb_io = BytesIO()
    if pil_img.mode in ('RGBA', 'P'): pil_img = pil_img.convert('RGB')
    pil_img.thumbnail((400, 400))
    pil_img.save(thumb_io, format='JPEG', quality=80)
    
    thumb_name = f"thumb_{file.name}"

    image_obj = Image.objects.create(
        owner=user,
        file=file,
        title=file.name,
        width=width,
        height=height,
        size=file.size,
        shot_time=shot_time,
        exif_data=exif_data,
        tags=[] 
    )
    image_obj.thumbnail.save(thumb_name, ContentFile(thumb_io.getvalue()), save=True)
    return image_obj

# 3. 批量删除 (新增)
@router.post("/images/bulk_delete", auth=None)
def bulk_delete_images(request, data: BulkDeleteIn):
    if not request.user.is_authenticated:
        from ninja.errors import HttpError
        raise HttpError(401, "请先登录")
    
    # 批量软删除
    count = Image.objects.filter(
        id__in=data.image_ids, 
        owner=request.user
    ).update(deleted_at=timezone.now())
    
    return {"success": True, "deleted_count": count}

# 4. 单张软删除
@router.delete("/images/{image_id}", auth=None)
def delete_image(request, image_id: UUID):
    if not request.user.is_authenticated:
        from ninja.errors import HttpError
        raise HttpError(401, "请先登录")
    
    img = get_object_or_404(Image, id=image_id, owner=request.user)
    img.deleted_at = timezone.now()
    img.save()
    return {"success": True, "message": "Moved to trash"}

# 5. 还原图片
@router.post("/images/{image_id}/restore", auth=None)
def restore_image(request, image_id: UUID):
    if not request.user.is_authenticated:
        from ninja.errors import HttpError
        raise HttpError(401, "请先登录")

    img = get_object_or_404(Image, id=image_id, owner=request.user)
    img.deleted_at = None
    img.save()
    return {"success": True, "message": "Restored"}

# 6. 永久删除
@router.delete("/images/{image_id}/hard", auth=None)
def hard_delete_image(request, image_id: UUID):
    if not request.user.is_authenticated:
        from ninja.errors import HttpError
        raise HttpError(401, "请先登录")

    img = get_object_or_404(Image, id=image_id, owner=request.user)
    if img.file: img.file.delete(save=False)
    if img.thumbnail: img.thumbnail.delete(save=False)
    img.delete()
    return {"success": True, "message": "Permanently deleted"}

# 7. 添加标签
@router.post("/images/{image_id}/tags", response=ImageOut, auth=None)
def add_tag(request, image_id: UUID, data: TagIn):
    if not request.user.is_authenticated:
        from ninja.errors import HttpError
        raise HttpError(401, "请先登录")

    img = get_object_or_404(Image, id=image_id, owner=request.user)
    if data.tag and data.tag not in img.tags:
        img.tags.append(data.tag)
        img.save()
    return img

# 8. 删除标签
@router.delete("/images/{image_id}/tags/{tag_name}", response=ImageOut, auth=None)
def remove_tag(request, image_id: UUID, tag_name: str):
    if not request.user.is_authenticated:
        from ninja.errors import HttpError
        raise HttpError(401, "请先登录")

    img = get_object_or_404(Image, id=image_id, owner=request.user)
    if tag_name in img.tags:
        img.tags.remove(tag_name)
        img.save()
    return img

# 9. 图片裁剪 (版本控制：不覆盖原图)
# 2. 升级：裁剪 + 色调调整 + 旋转
@router.post("/images/{image_id}/crop", response=ImageOut, auth=None)
def crop_image(request, image_id: UUID, data: CropIn):
    if not request.user.is_authenticated:
        from ninja.errors import HttpError
        raise HttpError(401, "请先登录")

    old_img = get_object_or_404(Image, id=image_id, owner=request.user)
    
    try:
        old_img.file.open()
        image_data = BytesIO(old_img.file.read())
        pil_img = PilImage.open(image_data)
        
        # A. 格式转换
        fmt = pil_img.format or 'JPEG'
        if pil_img.mode in ('RGBA', 'P') and fmt == 'JPEG':
            pil_img = pil_img.convert('RGB')

        # B. 旋转 (注意：CropperJS 传来的 rotate 是顺时针，PIL rotate 是逆时针)
        # 如果前端传来的旋转是 90 (顺时针)，PIL 需要 -90
        if data.rotate != 0:
            pil_img = pil_img.rotate(-data.rotate, expand=True)

        # C. 裁剪
        # 旋转后的画布尺寸可能变了，这里的 xy 应该是基于旋转后画布的坐标
        # CropperJS 的 getData() 已经帮我们计算好了相对于当前视觉画布的坐标
        box = (int(data.x), int(data.y), int(data.x + data.width), int(data.y + data.height))
        # 边界保护
        safe_box = (
            max(0, box[0]), 
            max(0, box[1]), 
            min(pil_img.width, box[2]), 
            min(pil_img.height, box[3])
        )
        cropped_img = pil_img.crop(safe_box)
        
        # D. 色调调整 (ImageEnhance)
        if data.brightness != 1.0:
            enhancer = ImageEnhance.Brightness(cropped_img)
            cropped_img = enhancer.enhance(data.brightness)
            
        if data.contrast != 1.0:
            enhancer = ImageEnhance.Contrast(cropped_img)
            cropped_img = enhancer.enhance(data.contrast)
            
        if data.saturation != 1.0:
            enhancer = ImageEnhance.Color(cropped_img)
            cropped_img = enhancer.enhance(data.saturation)

        # E. 保存新版本
        output_io = BytesIO()
        cropped_img.save(output_io, format=fmt, quality=95)
        
        original_name = old_img.file.name.split('/')[-1]
        new_filename = f"rev_{uuid.uuid4().hex[:8]}_{original_name}"
        
        new_img = Image.objects.create(
            owner=request.user,
            title=old_img.title,
            tags=old_img.tags,   
            exif_data=old_img.exif_data,
            shot_time=old_img.shot_time,
            width=cropped_img.width,
            height=cropped_img.height,
            size=output_io.tell()
        )
        
        new_img.file.save(new_filename, ContentFile(output_io.getvalue()), save=True)
        
        # 缩略图
        thumb_io = BytesIO()
        thumb_copy = cropped_img.copy()
        thumb_copy.thumbnail((400, 400))
        thumb_copy.save(thumb_io, format='JPEG', quality=80)
        
        new_img.thumbnail.save(f"thumb_{new_filename}", ContentFile(thumb_io.getvalue()), save=True)
        
        # 软删除旧图
        old_img.deleted_at = timezone.now()
        old_img.title = f"{old_img.title} (历史版本)"
        old_img.save()
        
        return new_img
        
    except Exception as e:
        print(f"Edit error: {str(e)}")
        from ninja.errors import HttpError
        raise HttpError(500, f"编辑失败: {str(e)}")

api.add_router("", router)