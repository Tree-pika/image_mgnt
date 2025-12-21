from transformers import pipeline
from PIL import Image as PilImage
import io

# 单例模式缓存模型，避免每次请求都重新加载
_classifier = None

def get_classifier():
    global _classifier
    if _classifier is None:
        print("正在加载 AI 模型 (google/vit-base-patch16-224)...")
        _classifier = pipeline("image-classification", model="google/vit-base-patch16-224")
        print("AI 模型加载完成！")
    return _classifier

def analyze_image(image_file):
    """
    接收 Django File 对象或 BytesIO，返回标签列表
    """
    try:
        # 确保指针在开始位置
        image_file.seek(0)
        
        # 将文件转为 PIL 图片
        image = PilImage.open(image_file)
        if image.mode != "RGB":
            image = image.convert("RGB")

        # 获取模型并预测
        classifier = get_classifier()
        results = classifier(image, top_k=3) # 取置信度最高的前3个结果
        
        # 提取标签
        tags = [res['label'].split(',')[0].lower() for res in results]
        
        return tags
    except Exception as e:
        print(f"AI Analysis Error: {e}")
        return []