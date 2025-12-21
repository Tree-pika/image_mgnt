from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User, Image

# 注册用户管理
admin.site.register(User, UserAdmin)

# 注册图片管理 
@admin.register(Image)
class ImageAdmin(admin.ModelAdmin):
    list_display = ('title', 'owner', 'created_at', 'deleted_at')
    list_filter = ('owner', 'created_at')
    search_fields = ('title', 'tags')
    
    # 管理员能直接看软删除的数据
    def get_queryset(self, request):
        return super().get_queryset(request)