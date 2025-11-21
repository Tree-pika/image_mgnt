from ninja import NinjaAPI, Router, File, Schema
from ninja.files import UploadedFile
from django.contrib.auth import authenticate, login, logout
# from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from django.conf import settings
from .models import Image
from .schemas import ImageOut, UserSchema # 导入刚才定义的 Schema
import os
import exifread
from PIL import Image as PilImage
from datetime import datetime
from io import BytesIO
from django.core.files.base import ContentFile

from django.http import HttpRequest
from .models import User
from django.db import IntegrityError
from pydantic import EmailStr

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

# --- 以下是图片上传逻辑 ---

def parse_exif_date(date_str):
    """辅助函数：将 EXIF 时间字符串 '2023:10:01 12:00:00' 转为 datetime 对象"""
    if not date_str:
        return None
    try:
        return datetime.strptime(str(date_str), '%Y:%m:%d %H:%M:%S')
    except ValueError:
        return None

@router.post("/upload", response=ImageOut, auth=None) # 暂时 auth=None 方便测试，之后需开启认证
def upload_image(request, file: UploadedFile = File(...)):
    # 1. 只有登录用户才能上传 (如果是 Session 认证，request.user.is_authenticated)
    # 这里的 request.user 依赖于你在 django settings 中配置了 Ninja 的 SessionAuth
    if not request.user.is_authenticated:
       # 为了方便目前测试，如果未登录，我们暂时把图挂在第一个用户头上
       # 正式上线请改为: return api.create_response(request, {"detail": "Unauthorized"}, status=401)
       user = User.objects.first()
    else:
       user = request.user

    # 2. 读取 EXIF 信息
    # file.file 是原本的 Python file object
    tags = exifread.process_file(file.file)
    file.file.seek(0) # 读取完后指针归位，否则 Pillow 读不到

    exif_data = {}
    shot_time = None
    
    # 提取拍摄时间
    if 'EXIF DateTimeOriginal' in tags:
        date_str = str(tags['EXIF DateTimeOriginal'])
        shot_time = parse_exif_date(date_str)
        exif_data['DateTimeOriginal'] = date_str
    
    # 提取相机型号等（可选）
    if 'Image Model' in tags:
        exif_data['Model'] = str(tags['Image Model'])

    # 3. 使用 Pillow 处理图片（获取宽高、生成缩略图）
    pil_img = PilImage.open(file.file)
    width, height = pil_img.size
    
    # 生成缩略图 (最大 400x400)
    thumb_io = BytesIO()
    pil_img.thumbnail((400, 400))
    # 保存为 JPEG 格式的缩略图
    pil_img.save(thumb_io, format='JPEG', quality=80)
    
    # 构造缩略图文件名
    thumb_name = f"thumb_{file.name}"

    # 4. 保存到数据库
    image_obj = Image.objects.create(
        owner=user,
        file=file,
        title=file.name,
        width=width,
        height=height,
        size=file.size,
        shot_time=shot_time,
        exif_data=exif_data,
        tags=[] # 初始为空列表
    )
    
    # 保存缩略图文件
    image_obj.thumbnail.save(thumb_name, ContentFile(thumb_io.getvalue()), save=True)

    return image_obj

api.add_router("", router)