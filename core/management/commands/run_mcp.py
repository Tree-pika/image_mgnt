import asyncio
import json
import os
import jieba
from django.core.management.base import BaseCommand
from django.conf import settings
from django.db.models import Q, Count
from asgiref.sync import sync_to_async
from mcp.server.fastmcp import FastMCP
from openai import OpenAI
import sys

# ================= 配置区域 =================
# deepseek
LLM_API_KEY = "sk-623ab52f77194040981c496cca52b1ed" 
LLM_BASE_URL = "https://api.deepseek.com"
LLM_MODEL = "deepseek-chat"
# ===========================================

mcp = FastMCP("CloudGallery")

class Command(BaseCommand):
    help = "启动 MCP Server"

    def handle(self, *args, **options):
        self.stderr.write(self.style.SUCCESS("正在启动 CloudGallery MCP Server..."))
        jieba.initialize()
        mcp.run()

# --- 关键词提取引擎 ---
def extract_search_keywords(user_query: str):
    """
    智能提取搜索词
    """
    clean_query = user_query.replace('"', '').replace("'", "").strip()
    if not clean_query:
        return [], "Empty Query"

    sys.stderr.write(f"\n--- 处理查询: '{clean_query}' ---")

    # === Level 1: DeepSeek ===
    if LLM_API_KEY and LLM_API_KEY.startswith("sk-"):
        try:
            client = OpenAI(api_key=LLM_API_KEY, base_url=LLM_BASE_URL)
            
            # 
            system_prompt = """
            你是一个图片搜索引擎的查询扩充助手。
            用户的输入可能是模糊的自然语言。你的任务是将其转换为数据库可能存在的 5-10 个搜索标签（Keywords）。
            
            重要规则：
            1. 数据库中的图片由 Google ViT 模型自动打标，标签全是英文单词（如 lakeside, seashore, comic, anime）。
            2. 请尽可能多地联想同义词。
            3. 如果用户输入中文，必须翻译成对应的多个英文标签，同时保留中文原词。
            
            示例：
            输入："找几张卡通图"
            输出：["cartoon", "anime", "animation", "comic", "manga", "drawing", "illustration", "卡通"]
            
            输入："风景"
            输出：["landscape", "scenery", "nature", "sky", "mountain", "river", "outdoor", "风景"]
            
            请只返回一个纯 JSON 字符串数组。
            """
            
            sys.stderr.write("🚀 [Level 1] 呼叫 DeepSeek 进行联想...")
            response = client.chat.completions.create(
                model=LLM_MODEL,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": clean_query}
                ],
                temperature=0.3, # 多猜词
                max_tokens=200,
                timeout=15
            )
            content = response.choices[0].message.content.strip()
            if content.startswith("```"):
                content = content.replace("```json", "").replace("```", "")
            
            keywords = json.loads(content)
            # 强制转小写
            keywords = [k.lower() for k in keywords]
            sys.stderr.write(f"✅ [Level 1] 扩展关键词: {keywords}")
            return keywords, "DeepSeek LLM"

        except Exception as e:
            sys.stderr.write(f"⚠️ [Level 1] 失败: {e}")

    # === Level 2: Jieba ===
    sys.stderr.write("🔄 [Level 2] Jieba 分词...")
    stop_words = {"帮我", "查找", "搜索", "寻找", "找", "和", "跟", "有关", "相关", "的", "图片", "照片", "图", "一下", "那个", "几张"}
    words = jieba.cut(clean_query)
    keywords = [w.lower() for w in words if w.strip() and w not in stop_words]
    
    if keywords:
        return keywords, "Jieba Keyword"

    # === Level 3: Raw ===
    return [clean_query.lower()], "Raw Query"

# --- 数据库操作 ---

@sync_to_async
def _authenticate_and_search(username, password, query, limit):
    from django.contrib.auth import authenticate
    from core.models import Image
    
    # 1. 鉴权
    user = authenticate(username=username, password=password)
    if not user:
        return None, "鉴权失败：用户名或密码错误", None, None

    # 2. 提取关键词
    keywords, source = extract_search_keywords(query)
    
    # 3. 查库 (强制限制 owner=user)
    qs = Image.objects.filter(owner=user, deleted_at__isnull=True)
    
    if keywords:
        q_obj = Q()
        for kw in keywords:
            q_obj |= Q(tags__contains=kw) | Q(title__icontains=kw) | Q(location__icontains=kw)
        qs = qs.filter(q_obj)
    
    results = []
    for img in qs.distinct().order_by('-created_at')[:limit]:
        results.append({
            "id": str(img.id),
            "title": img.title,
            "tags": img.tags,
            "file_path": img.file.name
        })
    return results, None, keywords, source

@sync_to_async
def _get_image_details_orm(image_id: str):
    from core.models import Image
    try:
        # 去除可能存在的空格
        clean_id = image_id.strip()
        img = Image.objects.get(id=clean_id)
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
            "exif": img.exif_data,
            "owner": img.owner.username # 增加拥有者信息
        }
    except Image.DoesNotExist:
        return None
    except Exception as e:
        return f"查询出错: {str(e)}"

@sync_to_async
def _get_statistics_orm():
    from core.models import Image
    from django.contrib.auth import get_user_model
    from collections import Counter
    
    User = get_user_model()
    
    # 1. 图片总数 (未删除的)
    total_images = Image.objects.filter(deleted_at__isnull=True).count()
    
    # 2. 用户总数
    total_users = User.objects.count()
    
    # 3. 每个用户的图片数量
    user_counts_qs = Image.objects.filter(deleted_at__isnull=True).values('owner__username').annotate(count=Count('id')).order_by('-count')
    user_stats = {item['owner__username']: item['count'] for item in user_counts_qs}
    
    # 4. 热门标签
    all_tags = []
    for img in Image.objects.filter(deleted_at__isnull=True):
        all_tags.extend(img.tags)
    
    top_tags = dict(Counter(all_tags).most_common(5))
    
    return {
        "total_images": total_images,
        "total_users": total_users,
        "images_per_user": user_stats,
        "top_tags": top_tags
    }

# --- MCP 工具定义 ---

@mcp.tool()
async def search_gallery(username: str, password: str, query: str, limit: int = 5) -> str:
    """
    智能搜索用户的个人相册。
    Args:
        username: 用户名
        password: 密码
        query: 用户的自然语言描述 (例如: "帮我找几张风景照")
    """
    
    # 获取结果 + 调试信息
    results, error, used_keywords, source = await _authenticate_and_search(username, password, str(query).strip(), limit)
    
    if error:
        return json.dumps({"error": error}, ensure_ascii=False)
    
    if not results:
        #
        return json.dumps({
            "status": "No Match",
            "message": f"用户 {username} 的相册中未找到相关图片。",
            "debug_info": {
                "original_query": str(query).strip(),
                "source": source,
                "used_keywords": used_keywords, 
                "hint": "请检查 used_keywords 是否包含你图片里实际有的英文标签。"
            }
        }, ensure_ascii=False, indent=2)
        
    return json.dumps(results, ensure_ascii=False, indent=2)



@mcp.tool()
async def get_image_metadata(image_id: str) -> str:
    """
    获取指定图片的详细元数据。
    Args:
        image_id: 图片的 UUID (例如: c422581d-fe9b...)
    """
    info = await _get_image_details_orm(image_id)
    if not info:
        return "错误：找不到该 ID 的图片。"
    if isinstance(info, str): # 错误信息
        return info
    return json.dumps(info, ensure_ascii=False, indent=2)

@mcp.tool()
async def get_gallery_stats() -> str:
    """
    获取相册的整体统计数据：包括图片总数、用户总数、各用户上传数量分布、热门标签。
    """
    stats = await _get_statistics_orm()
    return json.dumps(stats, ensure_ascii=False, indent=2)