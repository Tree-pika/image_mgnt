from django.db import models
from django.contrib.auth.models import AbstractUser
from django.contrib.auth import get_user_model
from django.conf import settings
import uuid

class User(AbstractUser):
    """
    自定义用户模型
    继承 Django 自带的 AbstractUser，保留了用户名、密码验证等核心功能。
    修改点：将 email 设为唯一，方便后续做邮箱登录或找回密码。
    """
    email = models.EmailField(unique=True)

#     class Meta:
#         verbose_name = '用户'
#         verbose_name_plural = '用户'

#     def __str__(self):
#         return self.username

# class Image(models.Model):
#     """
#     图片主表
#     """
#     # 使用 UUID 作为主键，比自增数字 ID (1, 2, 3...) 更安全，很难被爬虫猜到
#     id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
#     # 关联用户：User 表的一对多关系。
#     # on_delete=models.CASCADE 表示如果用户被删，他上传的图片也一并删除。
#     # related_name='images' 让我们能用 user.images.all() 反向查询。
#     owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='images')
    
#     # 图片文件：自动按 "uploads/2025/11/" 这样的年月结构存储
#     file = models.ImageField(upload_to='uploads/%Y/%m/')
    
#     title = models.CharField(max_length=100, blank=True)
    
#     # EXIF 信息：使用 MySQL 的 JSON 类型存储灵活的键值对
#     exif_data = models.JSONField(default=dict, blank=True)
    
#     # 关键元数据索引（用于快速筛选）
#     shot_time = models.DateTimeField(null=True, blank=True) # 拍摄时间
#     location = models.CharField(max_length=255, blank=True) # 拍摄地点
#     width = models.IntegerField(default=0)
#     height = models.IntegerField(default=0)

#     # AI 分析标签：存储 ["风景", "猫"] 这样的列表
#     tags = models.JSONField(default=list, blank=True)
    
#     created_at = models.DateTimeField(auto_now_add=True)

#     class Meta:
#         ordering = ['-created_at'] # 默认按创建时间倒序排列
        
#     def __str__(self):
#         return self.title or str(self.id)

class Image(models.Model):
    """图片主表"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='images')
    # upload_to 会根据日期自动分文件夹存储，例如 uploads/2025/11/
    file = models.ImageField(upload_to='uploads/%Y/%m/')
    thumbnail = models.ImageField(upload_to='thumbnails/%Y/%m/', blank=True, null=True) # 新增缩略图字段
    title = models.CharField(max_length=100, blank=True)
    
    # EXIF 信息 (功能 3)
    # 存储完整的原始 EXIF 数据，方便后续查看详情
    exif_data = models.JSONField(default=dict, blank=True) 
    
    # 关键元数据索引 (用于快速筛选)
    shot_time = models.DateTimeField(null=True, blank=True) # 拍摄时间
    location = models.CharField(max_length=255, blank=True) # 拍摄地点(预留)
    width = models.IntegerField(default=0)
    height = models.IntegerField(default=0)
    size = models.IntegerField(default=0) # 文件大小(字节)

    # 标签系统 (功能 4: 自定义标签, 增强功能 1: AI标签)
    # 这是一个列表，既包含 AI 分析的标签，也包含用户手动添加的自定义标签
    tags = models.JSONField(default=list, blank=True) 
    
    # --- 新增：软删除标记 ---
    deleted_at = models.DateTimeField(null=True, blank=True, db_index=True) # 加上索引加快查询
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.title or str(self.id)