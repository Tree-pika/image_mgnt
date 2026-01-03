from django.db import models
from django.contrib.auth.models import AbstractUser
from django.contrib.auth import get_user_model
from django.conf import settings
import uuid
from django.utils import timezone
import datetime
class User(AbstractUser):
    """
    自定义用户模型
    继承 Django 自带的 AbstractUser，保留了用户名、密码验证等核心功能。
    修改点：将 email 设为唯一，方便后续做邮箱登录或找回密码。
    """
    email = models.EmailField(unique=True)

class Image(models.Model):
    """图片主表"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='images')
    # upload_to 根据日期自动分文件夹存储
    file = models.ImageField(upload_to='uploads/%Y/%m/')
    thumbnail = models.ImageField(upload_to='thumbnails/%Y/%m/', blank=True, null=True) # 缩略图
    title = models.CharField(max_length=100, blank=True)
    
    # 存储完整的原始 EXIF 数据，方便后续查看详情
    exif_data = models.JSONField(default=dict, blank=True) 
    
    # 关键元数据索引 (快速筛选)
    shot_time = models.DateTimeField(null=True, blank=True) # 拍摄时间
    location = models.CharField(max_length=255, blank=True) # 拍摄地点
    width = models.IntegerField(default=0)
    height = models.IntegerField(default=0)
    size = models.IntegerField(default=0) # 文件大小(字节)

    # 标签列表，既包含 AI 分析的标签，也包含用户手动添加的自定义标签
    tags = models.JSONField(default=list, blank=True) 
    
    # --- 软删除标记 ---
    deleted_at = models.DateTimeField(null=True, blank=True, db_index=True) # 加上索引加快查询
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.title or str(self.id)

class EmailVerification(models.Model):
    """
    存储邮箱验证码的临时表
    """
    email = models.EmailField()
    code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    
    # 验证码有效期：5 分钟
    def is_valid(self):
        now = timezone.now()
        return now - self.created_at < datetime.timedelta(minutes=5)