import asyncio
import json
from django.core.management.base import BaseCommand
from django.conf import settings
from django.db.models import Q
from asgiref.sync import sync_to_async
from mcp.server.fastmcp import FastMCP

# 初始化 FastMCP 服务
mcp = FastMCP("CloudGallery")

class Command(BaseCommand):
    help = "启动 MCP (Model Context Protocol) 服务器，供 AI 客户端连接"

    def handle(self, *args, **options):
        self.stdout.write(self.style.SUCCESS("正在启动 CloudGallery MCP Server..."))
        # 启动 MCP 服务 (stdio 模式)
        mcp.run()

# --- 辅助函数：异步封装 Django ORM ---
# 因为 MCP 是异步运行的，而 Django ORM 默认是同步的，必须转换

@sync_to_async
def _search_images_orm(query: str, limit: int):
    # 复用我们在 Step 8 实现的统一搜索逻辑
    from core.models import Image
    
    qs = Image.objects.filter(deleted_at__isnull=True)
    
    if query:
        qs = qs.filter(
            Q(title__icontains=query) | 
            Q(location__icontains=query) | 
            Q(tags__contains=query)
        )
    
    # 获取结果
    results = []
    for img in qs.order_by('-created_at')[:limit]:
        results.append({
            "id": str(img.id),
            "title": img.title,
            "date": img.shot_time.strftime('%Y-%m-%d %H:%M') if img.shot_time else "未知",
            "tags": img.tags,
            "width": img.width,
            "height": img.height,
            "file_path": img.file.name
        })
    return results

@sync_to_async
def _get_image_details_orm(image_id: str):
    from core.models import Image
    try:
        img = Image.objects.get(id=image_id)
        return {
            "id": str(img.id),
            "title": img.title,
            "metadata": {
                "size_kb": round(img.size / 1024, 2),
                "resolution": f"{img.width}x{img.height}",
                "shot_time": str(img.shot_time),
                "location": img.location,
            },
            "tags": img.tags,
            "exif": img.exif_data
        }
    except Image.DoesNotExist:
        return None

@sync_to_async
def _get_statistics_orm():
    from core.models import Image
    total = Image.objects.filter(deleted_at__isnull=True).count()
    # 统计热门标签 (简单实现)
    all_tags = []
    for img in Image.objects.filter(deleted_at__isnull=True):
        all_tags.extend(img.tags)
    
    from collections import Counter
    top_tags = Counter(all_tags).most_common(5)
    
    return {
        "total_images": total,
        "top_tags": dict(top_tags)
    }

# --- MCP 工具定义 ---
# 这些函数会被暴露给 AI 模型调用

@mcp.tool()
async def search_gallery(query: str, limit: int = 5) -> str:
    """
    搜索相册中的图片。
    Args:
        query: 搜索关键词 (可以是标签、地点或标题，如 风景, 猫, 2023)
        limit: 返回的最大数量 (默认 5)
    """
    results = await _search_images_orm(query, limit)
    if not results:
        return "未找到相关图片。"
    return json.dumps(results, ensure_ascii=False, indent=2)

@mcp.tool()
async def get_image_metadata(image_id: str) -> str:
    """
    获取指定图片的详细元数据 (EXIF, 分辨率, 完整标签等)。
    Args:
        image_id: 图片的 UUID
    """
    info = await _get_image_details_orm(image_id)
    if not info:
        return "错误：找不到该 ID 的图片。"
    return json.dumps(info, ensure_ascii=False, indent=2)

@mcp.tool()
async def get_gallery_stats() -> str:
    """
    获取相册的整体统计数据，如图片总数、最热门的标签。
    """
    stats = await _get_statistics_orm()
    return json.dumps(stats, ensure_ascii=False, indent=2)