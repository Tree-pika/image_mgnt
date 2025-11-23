from ninja import NinjaAPI, Router, File, Schema
from ninja.files import UploadedFile
from django.contrib.auth import authenticate, login, logout
# from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import get_user_model
# from django.shortcuts import get_object_or_404
from django.conf import settings
from .models import Image
from .schemas import ImageOut, UserSchema # 导入刚才定义的 Schema
import exifread
from PIL import Image as PilImage
from datetime import datetime
from io import BytesIO
from django.core.files.base import ContentFile

from django.http import HttpRequest
from .models import User
from django.db import IntegrityError
from pydantic import EmailStr

from typing import List
from django.db.models import Q

# 实例化 API 对象
api = NinjaAPI()
router = Router()

User = get_user_model()

# --- Schemas (数据校验模型) ---

class RegisterSchema(Schema):
    username: str
    password: str
    email: EmailStr # 自动校验邮箱格式

class LoginSchema(Schema):
    username: str
    password: str

class ErrorSchema(Schema):
    message: str

# --- API Endpoints (接口逻辑) ---

@api.post("/auth/register", response={200: UserSchema, 400: ErrorSchema})
def register(request, data: RegisterSchema):
    """用户注册接口"""
    # 1. 校验密码长度
    if len(data.password) < 6:
        return 400, {"message": "密码长度至少需要6位"}
    
    try:
        # 2. 创建用户 (create_user 会自动处理密码哈希加密)
        user = User.objects.create_user(
            username=data.username,
            password=data.password,
            email=data.email
        )
        return 200, user
    except IntegrityError:
        # 3. 捕获用户名或邮箱重复的错误
        return 400, {"message": "用户名或邮箱已存在"}

@api.post("/auth/login", response={200: UserSchema, 400: ErrorSchema})
def user_login(request: HttpRequest, data: LoginSchema):
    """
    用户登录接口 (支持 用户名 或 邮箱 登录)
    """
    username = data.username
    # 1. 如果输入包含 @，则认为是邮箱登录
    if '@' in username:
        # 先根据邮箱找到对应的 User 对象
        user_obj = User.objects.filter(email=username).first()
        if user_obj:
            # 将邮箱转换为该用户的真实用户名，传给 authenticate
            username = user_obj.username
    
    # 2. 执行标准验证
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
    """获取当前登录用户信息（测试 Session 是否生效）"""
    if request.user.is_authenticated:
        return 200, request.user
    return 403, {"message": "未登录"}

# --- 图片上传逻辑 ---

def parse_exif_date(date_str):
    """辅助函数：将 EXIF 时间字符串 '2023:10:01 12:00:00' 转为 datetime 对象"""
    if not date_str:
        return None
    try:
        return datetime.strptime(str(date_str), '%Y:%m:%d %H:%M:%S')
    except ValueError:
        return None

# 1. 获取图片列表
@router.get("/images", response=List[ImageOut])
def list_images(request, search: str = None, tag: str = None):    
    # 允许查看所有图片
    # qs = Image.objects.all() 
    
    # 只能看自己上传的照片：
    if not request.user.is_authenticated: 
        return []
    qs = Image.objects.filter(owner=request.user)
    
    # 搜索逻辑
    if search:
        qs = qs.filter(Q(title__icontains=search) | Q(location__icontains=search))
    
    if tag:
        qs = qs.filter(tags__contains=tag)
        
    return qs.order_by('-created_at')

# 2. 上传图片
@router.post("/upload", response=ImageOut, auth=None) 
def upload_image(request, file: UploadedFile = File(...)):
    # 严格检查，不再使用 fallback
    if not request.user.is_authenticated:
       from ninja.errors import HttpError
       raise HttpError(401, "请先登录")
    
    user = request.user

    # 读取 EXIF
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

    # Pillow 处理
    pil_img = PilImage.open(file.file)
    width, height = pil_img.size
    
    thumb_io = BytesIO()
    # 转换为 RGB 防止 PNG 透明背景变黑
    if pil_img.mode in ('RGBA', 'P'):
        pil_img = pil_img.convert('RGB')
        
    pil_img.thumbnail((400, 400))
    pil_img.save(thumb_io, format='JPEG', quality=80)
    
    thumb_name = f"thumb_{file.name}"

    # 保存数据库
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

api.add_router("", router)