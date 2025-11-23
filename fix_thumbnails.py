import os
import django
from io import BytesIO
from PIL import Image as PilImage
from django.core.files.base import ContentFile

# 初始化 Django 环境
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from core.models import Image

def regenerate_thumbnails():
    print("开始检查并修复缩略图...")
    images = Image.objects.all()
    count = 0
    
    for img in images:
        # 1. 检查原图是否存在
        if not img.file or not os.path.exists(img.file.path):
            print(f"[跳过] ID {img.id}: 原文件丢失")
            continue

        # 2. 检查缩略图是否丢失
        need_fix = False
        if not img.thumbnail:
            need_fix = True
        elif not os.path.exists(img.thumbnail.path):
            need_fix = True
            
        if need_fix:
            print(f"[修复中] ID {img.id}: 生成缩略图...")
            try:
                # 生成逻辑
                pil_img = PilImage.open(img.file.path)
                if pil_img.mode in ('RGBA', 'P'):
                    pil_img = pil_img.convert('RGB')
                
                thumb_io = BytesIO()
                thumb_copy = pil_img.copy()
                thumb_copy.thumbnail((400, 400))
                thumb_copy.save(thumb_io, format='JPEG', quality=80)
                
                # 保存
                file_name = f"thumb_{img.file.name.split('/')[-1]}"
                img.thumbnail.save(file_name, ContentFile(thumb_io.getvalue()), save=True)
                count += 1
            except Exception as e:
                print(f"[失败] ID {img.id}: {e}")

    print(f"完成！共修复 {count} 张图片。")

if __name__ == '__main__':
    regenerate_thumbnails()